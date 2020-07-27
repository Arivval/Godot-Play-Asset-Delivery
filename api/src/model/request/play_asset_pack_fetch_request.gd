# ##############################################################################
#
#	Copyright 2020 Google LLC
#
#	Licensed under the Apache License, Version 2.0 (the "License");
#	you may not use this file except in compliance with the License.
#	You may obtain a copy of the License at
#
#		https://www.apache.org/licenses/LICENSE-2.0
#
#	Unless required by applicable law or agreed to in writing, software
#	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.
#
# ##############################################################################
#
# Request object that handles asynchronous logic related to fetch_asset_pack().
#
# This object provides relevant getters so that it is possible to retrieve
# the updated states from this object upon every state update.
#
# ##############################################################################
class_name PlayAssetPackFetchRequest
extends PlayAssetDeliveryRequest

# -----------------------------------------------------------------------------
# Emits request_completed(pack_name, result, exception) signal 
# upon request reached terminal state {COMPLETED, CANCELED, FAILED}
# 	pack_name: String, name of the requested asset pack
# 	result : PlayAssetPackState object
#	exception: PlayAssetPackException object if Plugin encountered an exception
# while handling this request
# -----------------------------------------------------------------------------
signal request_completed(pack_name, result, exception)

var _pack_name : String
var _state : PlayAssetPackState
var _error : PlayAssetPackException

# used for unit testing
var _stub_play_asset_pack_manager

func _init(pack_name):
	_pack_name = pack_name
	
	# _state will be defaulted with status of UNKNOWN
	var default_pack_dict = {
		PlayAssetPackState._NAME_KEY: pack_name, 
		PlayAssetPackState._STATUS_KEY: PlayAssetPackManager.AssetPackStatus.UNKNOWN, 
		PlayAssetPackState._ERROR_CODE_KEY: PlayAssetPackManager.AssetPackErrorCode.NO_ERROR,
		PlayAssetPackState._BYTES_DOWNLOADED_KEY: 0,
		PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY: 0,
		PlayAssetPackState._TRANSFER_PROGRESS_PERCENTAGE_KEY: 0
	}
	_state = PlayAssetPackState.new(default_pack_dict)
	
# -----------------------------------------------------------------------------
# Returns the requested asset pack's name.
# -----------------------------------------------------------------------------
func get_pack_name() -> String:
	return _pack_name

# -----------------------------------------------------------------------------
# Returns whether this request is completed or not.
# -----------------------------------------------------------------------------
func get_is_completed() -> bool:
	var is_non_existing_pack_exception = _state.get_status() == PlayAssetPackManager.AssetPackStatus.UNKNOWN \
		and _state.get_error_code() == PlayAssetPackManager.AssetPackErrorCode.INTERNAL_ERROR
	var is_terminal_state = _state.get_status() in PlayAssetPackManager._PACK_TERMINAL_STATES
	
	return is_terminal_state or is_non_existing_pack_exception

# -----------------------------------------------------------------------------
# Returns the most up-to-date PlayAssetPackState object.
# -----------------------------------------------------------------------------
func get_state() -> PlayAssetPackState:
	return _state

# -----------------------------------------------------------------------------
# Returns a PlayAssetPackException if exception occurred.
# -----------------------------------------------------------------------------
func get_error() -> PlayAssetPackException:
	return _error

# -----------------------------------------------------------------------------
# Callback functions handling signals emitted from the plugin.
# -----------------------------------------------------------------------------
func _on_fetch_success(result: Dictionary):
	# Since fetch() in plugin returns a PlayAssetPackStates Dictionary, we need to extract
	# the PlayAssetPackState within.
	var fetch_asset_pack_states_dict = PlayAssetPackStates.new(result).get_pack_states()
	
	if fetch_asset_pack_states_dict.has(_pack_name):
		_on_state_updated(fetch_asset_pack_states_dict[_pack_name].to_dict())
		# emit non-duplicating state_updated signal
		if _stub_play_asset_pack_manager == null:
			PlayAssetPackManager._forward_high_level_state_updated_signal(_pack_name, _state.to_dict())
		else:
			_stub_play_asset_pack_manager._forward_high_level_state_updated_signal(_pack_name, _state.to_dict())	
	else:
		# Although we received a fetchSuccess signal, the result field does not contain
		# needed AssetPackState dictionary. Hence update _state's error_code to INTERNAL_ERROR
		# and emit and request_completed signal.
		_state._error_code = PlayAssetPackManager.AssetPackErrorCode.INTERNAL_ERROR
		# release reference
		PlayAssetPackManager._remove_request_reference_from_map(_pack_name)
		emit_signal("request_completed", _pack_name, _state, null)

func _on_fetch_error(error: Dictionary):
	_state._status = PlayAssetPackManager.AssetPackStatus.FAILED
	_state._error_code = PlayAssetPackManager.AssetPackErrorCode.INTERNAL_ERROR
	_error = PlayAssetPackException.new(error)
	emit_signal("request_completed", _pack_name, _state, _error)
	# emit non-duplicating state_updated signal
	if _stub_play_asset_pack_manager == null:
		PlayAssetPackManager._forward_high_level_state_updated_signal(_pack_name, _state.to_dict())
	else:
		_stub_play_asset_pack_manager._forward_high_level_state_updated_signal(_pack_name, _state.to_dict())

func _on_state_updated(result: Dictionary):
	_state = PlayAssetPackState.new(result)
	if _state.get_status() in PlayAssetPackManager._PACK_TERMINAL_STATES:
		# reached a terminal state, emit request_completed signal
		emit_signal("request_completed", _pack_name, _state, null)
		

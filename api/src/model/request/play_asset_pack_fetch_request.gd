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
# the updated states from this object once the request completes.
#
# ##############################################################################
class_name PlayAssetPackFetchRequest
extends PlayAssetDeliveryRequest

# -----------------------------------------------------------------------------
# Emits request_completed(did_succeed, pack_name, result, exception) signal 
# upon request succeeds(reaching CANCELED/COMPLETED)/fails(reaching FAILED).
# 	did_succeed : boolean indicating request succeeded/failed
# 	pack_name: String, name of the requested asset pack
# 	result : PlayAssetPackState object
#	exception: PlayAssetPackException object if Plugin encountered an exception
# while handling this request
#
# Note: when calling fetch_asset_pack() on a non-existent pack_name, 
# did_succeed will be false and state's status will be INVALID_REQUEST
# -----------------------------------------------------------------------------
signal request_completed(did_succeed, pack_name, result, exception)

var _pack_name : String
var _did_succeed : bool
var _state : PlayAssetPackState
var _error : PlayAssetPackException

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
# Returns boolean indicating Request succeeded/failed.
# -----------------------------------------------------------------------------
func get_did_succeed() -> bool:
	return _did_succeed

# -----------------------------------------------------------------------------
# Returns the most up-to-date PlayAssetPackState object, null if Request failed.
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
	else:
		# Although we received a fetchSuccess signal, the result field does not contain
		# needed AssetPackState dictionary. Hence update _state's error_code to INVALID_REQUEST
		# and emit and request_completed signal.
		_did_succeed = false
		_state._error_code = PlayAssetPackManager.AssetPackErrorCode.INVALID_REQUEST
		# release reference
		PlayAssetPackManager._remove_request_reference_from_map(_pack_name)
		emit_signal("request_completed", _did_succeed, _pack_name, _state, null)

func _on_fetch_error(error: Dictionary):
	_did_succeed = false
	_state._status = PlayAssetPackManager.AssetPackStatus.FAILED
	_state._error_code = PlayAssetPackManager.AssetPackErrorCode.INTERNAL_ERROR
	_error = PlayAssetPackException.new(error)
	emit_signal("request_completed", _did_succeed, _pack_name, _state, _error)
	PlayAssetPackManager._forward_high_level_state_updated_signal(_pack_name, _state.to_dict())

func _on_state_updated(result: Dictionary):
	_did_succeed = true
	_state = PlayAssetPackState.new(result)
	if _state.get_status() in PlayAssetPackManager._PACK_TERMINAL_STATES:
		# reached a terminal state, emit request_completed signal
		emit_signal("request_completed", _did_succeed, _pack_name, _state, null)

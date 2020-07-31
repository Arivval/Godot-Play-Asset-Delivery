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
# Request object that handles asynchronous logic related to 
# get_asset_pack_state() and provides most updated PlayAssetPackState of a
# given asset pack.
# 
# This object provides relevant getters so that it is possible to retrieve
# the updated state from this object once the request completes.
#
# ##############################################################################
# Suppress unused_signal warning because Godot cannot detect signal usage when 
# we call emit_signal() using call_deferred().
# warning-ignore:unused_signal
class_name PlayAssetPackStateRequest
extends PlayAssetDeliveryRequest

# -----------------------------------------------------------------------------
# Emits request_completed(did_succeed, pack_name, result, exception) signal 
# upon request succeeds/fails.
# 	did_succeed : boolean indicating request succeeded/failed
# 	pack_name: String, name of the requested asset pack
# 	result : PlayAssetPackState object if request succeeded, otherwise null
#	exception: PlayAssetPackException object if request failed, otherwise null
#
# Note: when calling get_asset_pack_state() on a non-existent pack_name, 
# did_succeed will be false and both result and exception will be null.
# -----------------------------------------------------------------------------
signal request_completed(did_succeed, pack_name, result, exception)

var _pack_name : String
var _did_succeed : bool
var _result : PlayAssetPackState
var _error : PlayAssetPackException

func _init(pack_name):
	_pack_name = pack_name

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
# Returns the result of a succeeded Request, represent by a PlayAssetPackState 
# object.
# -----------------------------------------------------------------------------
func get_result() -> PlayAssetPackState:
	return _result

# -----------------------------------------------------------------------------
# Returns a PlayAssetPackException if exception occurred.
# -----------------------------------------------------------------------------
func get_error() -> PlayAssetPackException:
	return _error

# -----------------------------------------------------------------------------
# Callback functions handling signals emitted from the plugin.
# -----------------------------------------------------------------------------
func _on_get_asset_pack_state_success(result : Dictionary):
	# Since getPackStates() in plugin returns a PlayAssetPackStates Dictionary, we need to extract
	# the PlayAssetPackState within.
	var updated_asset_pack_states_dict = PlayAssetPackStates.new(result).get_pack_states()
	if updated_asset_pack_states_dict.has(_pack_name):
		_did_succeed = true
		_result = updated_asset_pack_states_dict[_pack_name]
		call_deferred("emit_signal", "request_completed", _did_succeed, _pack_name, _result, null)
	else:
		# Although we received a getPackStatesSuccess signal, the result field does not contain
		# needed AssetPackState dictionary. Hence emit a failing signal where both result and error
		# are null.
		_did_succeed = false
		call_deferred("emit_signal", "request_completed", _did_succeed, _pack_name, null, null)	

func _on_get_asset_pack_state_error(error: Dictionary):
	_did_succeed = false
	_error = PlayAssetPackException.new(error)
	call_deferred("emit_signal", "request_completed", _did_succeed, _pack_name, null, _error)	


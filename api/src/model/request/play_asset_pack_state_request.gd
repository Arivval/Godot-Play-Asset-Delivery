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
# the updated states from this object once the request completes.
#
# ##############################################################################
class_name PlayAssetPackStateRequest
extends PlayAssetDeliveryRequest

signal request_completed(did_succeed, result, exception)

var _did_succeed : bool
var _result : PlayAssetPackState
var _error : PlayAssetPackException
var _pack_name : String

func _init(pack_name):
	_pack_name = pack_name

# -----------------------------------------------------------------------------
# Returns boolean indicating Request succeeded/failed.
# -----------------------------------------------------------------------------
func get_did_succeed() -> bool:
	return _did_succeed

# -----------------------------------------------------------------------------
# Returns the result of a succeeded Request, represent by a 
# CellularDataConfirmationResult enum.
# -----------------------------------------------------------------------------
func get_result() -> PlayAssetPackState:
	return _result

# -----------------------------------------------------------------------------
# Returns a PlayAssetPackException if Request failed.
# -----------------------------------------------------------------------------
func get_error() -> PlayAssetPackException:
	return _error

# -----------------------------------------------------------------------------
# Callback functions handling signals emitted from the plugin.
#
# Emits request_completed(did_succeed, result, exception) signal upon request 
# succeeds/fails.
# 	did_succeed : boolean indicating request succeeded/failed
# 	result : PlayAssetPackState object if request succeeded, otherwise null
#	exception: PlayAssetPackException object if request failed, otherwise null
# -----------------------------------------------------------------------------
func _on_get_asset_pack_state_success(result : Dictionary):
	_did_succeed = true
	# getPackStates() in plugin returns a PlayAssetPackStates Dictionary
	# TODO: exact behavior of get non-existent pack state.
	# Currently we are handling as if the plugin won't emit an error, but we will have an empty 
	# pack_states Dictionary. Hence if we encounter this situation we would consider it as 
	# request failed.
	var updated_asset_pack_states_dict = PlayAssetPackStates.new(result).get_pack_states()
	if updated_asset_pack_states_dict.size() == 1 and _pack_name in updated_asset_pack_states_dict.keys():
		_result = updated_asset_pack_states_dict[_pack_name]
		call_deferred("emit_signal", "request_completed", true, _result, null)
	else:
		# emit a failing signal where both result and error are null
		call_deferred("emit_signal", "request_completed", false, null, null)	

func _on_get_asset_pack_state_error(error: Dictionary):
	_did_succeed = false
	_error = PlayAssetPackException.new(error)
	call_deferred("emit_signal", "request_completed", false, null, _error)	



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
# upon request succeeds/fails.
# 	did_succeed : boolean indicating request succeeded/failed
# 	pack_name: String, name of the requested asset pack
# 	result : PlayAssetPackState object if request succeeded, otherwise null
#	exception: PlayAssetPackException object if request failed, otherwise null
#
# Note: when calling get_asset_pack_state() on a non-existent pack_name, 
# did_succeed will be false and both result and exception will be null.
# Emits state_updated(pack_name, result) signal upon fetched pack's state 
# updated.
# 	pack_name: String, name of the requested asset pack
# 	result: most up-to-date PlayAssetPackState object
# -----------------------------------------------------------------------------
signal request_completed(did_succeed, pack_name, result, exception)
signal state_updated(pack_name, result)

var _pack_name : String
var _did_succeed : bool
var _state : PlayAssetPackState
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
	_did_succeed = true
	_state = PlayAssetPackState.new(result)
	call_deferred("emit_signal", "request_completed", true, _pack_name, _state, null)

func _on_fetch_error(error: Dictionary):
	_did_succeed = false
	_error = PlayAssetPackException.new(error)
	call_deferred("emit_signal", "request_completed", false, _pack_name, null, _error)

func _on_state_updated(result: Dictionary):
	_state = PlayAssetPackState.new(result)
	call_deferred("emit_signal", "state_updated", _state)


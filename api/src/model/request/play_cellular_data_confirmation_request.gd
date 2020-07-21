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
# show_cellular_data_confirmation().
# 
# This object provides relevant getters so that it is possible to retrieve
# the updated states from this object once the request completes.
#
# ##############################################################################
class_name PlayCellularDataConfirmationRequest
extends PlayAssetDeliveryRequest

signal request_completed(did_succeed, result, exception)

var _did_succeed : bool
var _result : int
var _error : PlayAssetPackException

# -----------------------------------------------------------------------------
# Returns boolean indicating Request succeeded/failed.
# -----------------------------------------------------------------------------
func get_did_succeed() -> bool:
	return _did_succeed

# -----------------------------------------------------------------------------
# Returns the result of a succeeded Request, represent by an 
# AssetPackStorageMethod enum.
# -----------------------------------------------------------------------------
func get_result() -> int:
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
# 	result : AssetPackStorageMethod enum if request succeeded, otherwise -1
#	exception: PlayAssetPackException object if request failed, otherwise null
# -----------------------------------------------------------------------------
func _on_show_cellular_data_confirmation_success(result : int):
	_did_succeed = true
	_result = result
	emit_signal("request_completed", true, result, null)

func _on_show_cellular_data_confirmation_error(error: Dictionary):
	_did_succeed = false
	_error = PlayAssetPackException.new(error)
	emit_signal("request_completed", false, -1, _error)	



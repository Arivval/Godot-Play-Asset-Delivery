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
# Request object that handles asynchronous logic related to remove_pack().
# 
# Emits request_completed signal upon success/error. For this signal, the first 
# boolean argument will be true and the second argument will be null if remove 
# request succeeds. Otherwise the second argument will contain a 
# PlayAssetPackException object representing the exception encountered.
#
# This object also provides relevant getters so that it is possible to retrieve
# the updated states from this object using the yield to signal approach.
#
# ##############################################################################
class_name PlayAssetPackRemoveRequest
extends PlayAssetDeliveryRequest

signal request_completed

var _status : bool
var _error : PlayAssetPackException

# -----------------------------------------------------------------------------
# Returns boolean indicating Request succeeded/failed.
# -----------------------------------------------------------------------------
func get_status() -> bool:
	return _status

# -----------------------------------------------------------------------------
# Returns a PlayAssetPackException if Request failed, else returns null.
# -----------------------------------------------------------------------------
func get_error() -> PlayAssetPackException:
	return _error

# -----------------------------------------------------------------------------
# Callback functions handling signals emitted from the plugin.
# -----------------------------------------------------------------------------
func on_remove_pack_success():
	_status = true
	emit_signal("request_completed", true, null)

func on_remove_pack_error(error: Dictionary):
	_status = false
	_error = PlayAssetPackException.new(error)
	emit_signal("request_completed", false, _error)



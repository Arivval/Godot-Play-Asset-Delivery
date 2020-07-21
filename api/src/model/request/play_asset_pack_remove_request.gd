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
# Request object that handles asychronous logic related to remove_pack().
# 
# Emits request_completed signal upon success/error.
# The first boolean argument is true is remove request is success.
# If success the second argument will be null. Else the second argument will
# contain a PlayAssetPackException object representing the exception encountered.
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
	var exception_object = PlayAssetPackException.new(error)
	_error = exception_object
	emit_signal("request_completed", false, exception_object)



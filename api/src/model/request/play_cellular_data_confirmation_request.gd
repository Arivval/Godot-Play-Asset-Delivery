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
# Request object that handles asychronous logic related to 
# show_cellular_data_confirmation().
#
# Emits request_completed signal upon success/error.
# The first boolean argument will be true if remove request succeeds.
# If success the second arguemtn will be contain the integer result, represented
# by an AssetPackStorageMethod enum. Else the second argument will contain a 
# PlayAssetPackException object representing the exception encountered.
# 
# This object also provides relevant getters so that it is possible to retrieve
# the updated states from this object using the yield to signal approach.
#
# ##############################################################################
class_name PlayCellularDataConfirmationRequest
extends PlayAssetDeliveryRequest

signal request_completed


var _status : bool
var _result : int
var _error : PlayAssetPackException

# -----------------------------------------------------------------------------
# Returns the boolean status, true if Request succeeded, false if failed.
# -----------------------------------------------------------------------------
func get_status() -> bool:
	return _status

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

func on_show_cellular_data_confirmation_success(result : int):
	_status = true
	_result = result
	emit_signal("request_completed", true, result)

func on_show_cellular_data_confirmation_error(error: Dictionary):
	var exception_object = PlayAssetPackException.new(error)
	_status = false
	_error = exception_object
	emit_signal("request_completed", false, exception_object)



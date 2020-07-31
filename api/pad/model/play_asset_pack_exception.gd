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
# Object used to represent AssetPackExceptions or Java Exceptions occured during
# Android plugin calls. If exception type is AssetPackException, the error_code
# will be represented using an AssetPackErrorCode enum. Otherwise error_code will 
# be default to AssetPackErrorCode.INTERNAL_ERROR.
#
# ##############################################################################
class_name PlayAssetPackException
extends Object

# -----------------------------------------------------------------------------
# Constant declaration for Dictionary key Strings
# -----------------------------------------------------------------------------
const _TYPE_KEY : String = "type"
const _MESSAGE_KEY : String = "message"
const _ERROR_CODE_KEY : String = "errorCode"

var _type : String
var _message : String
var _error_code : int

func _init(init_dictionary : Dictionary):
	_type = init_dictionary[_TYPE_KEY]
	_message = init_dictionary[_MESSAGE_KEY]
	_error_code = init_dictionary[_ERROR_CODE_KEY]
	
# -----------------------------------------------------------------------------
# Returns the type of the exception, derived using 
# exception.getClass().getCanonicalName().
# -----------------------------------------------------------------------------
func get_type() -> String:
	return _type

# -----------------------------------------------------------------------------
# Returns the exception message, derived using exception.getMessage().
# -----------------------------------------------------------------------------
func get_message() -> String:
	return _message

# -----------------------------------------------------------------------------
# Returns the error code of the exception, represented using the 
# AssetPackErrorCode enum.
# -----------------------------------------------------------------------------
func get_error_code() -> int:
	return _error_code

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
# Wraps Play Core's AssetPackState which represents the state of an individual 
# asset pack.
#
# ##############################################################################
class_name PlayAssetPackState
extends Object

var _name : String
var _status : int
var _error_code : int
var _bytes_downloaded : int
var _total_bytes_to_download : int
var _transfer_progress_percentage : int

func _init(init_dictionary : Dictionary):
	_name = init_dictionary["name"]
	_status = init_dictionary["status"]
	_error_code = init_dictionary["errorCode"]
	_bytes_downloaded = init_dictionary["bytesDownloaded"]
	_total_bytes_to_download = init_dictionary["totalBytesToDownload"]
	_transfer_progress_percentage = init_dictionary["transferProgressPercentage"]

# -----------------------------------------------------------------------------
# Returns the name of the pack.
# -----------------------------------------------------------------------------
func get_name() -> String:
	return _name

# -----------------------------------------------------------------------------
# Returns an int from PlayAssetPackManager.AssetPackStatus enum, represents
# the download status of the pack.
# -----------------------------------------------------------------------------
func get_status() -> int:
	return _status

# -----------------------------------------------------------------------------
# Returns the error code (int from PlayAssetPackManager.AssetPackErrorCode enum)
# for the pack, if Play has failed to download the pack.
# -----------------------------------------------------------------------------
func get_error_code() -> int:
	return _error_code

# -----------------------------------------------------------------------------
# Returns the total number of bytes already downloaded for the pack.
# -----------------------------------------------------------------------------
func get_bytes_downloaded() -> int:
	return _bytes_downloaded

# -----------------------------------------------------------------------------
# Returns the total size of the pack in bytes.
# -----------------------------------------------------------------------------
func get_total_bytes_to_download() -> int:
	return _total_bytes_to_download

# -----------------------------------------------------------------------------
# Returns the percentage of the asset pack already transferred to the app.
# -----------------------------------------------------------------------------
func get_transfer_progress_percentage() -> int:
	return _transfer_progress_percentage

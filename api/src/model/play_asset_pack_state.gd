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
#
# ##############################################################################
class_name PlayAssetPackState
extends Object

var _asset_pack_state_dict : Dictionary

func _init(init_dictionary : Dictionary):
	_asset_pack_state_dict = _asset_pack_state_dict.duplicate()

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
func get_name() -> String:
	return _asset_pack_state_dict["name"]

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
func get_status() -> int:
	return _asset_pack_state_dict["status"]

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
func get_error_code() -> int:
	return _asset_pack_state_dict["errorCode"]

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
func get_bytes_downloaded() -> int:
	return _asset_pack_state_dict["bytesDownloaded"]

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
func get_total_bytes_to_download() -> int:
	return _asset_pack_state_dict["totalBytesToDownload"]

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
func get_transfer_progress_percentage() -> int:
	return _asset_pack_state_dict["transferProgressPercentage"]

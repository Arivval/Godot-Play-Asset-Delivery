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
# Base test class that inherits from gut/test.gd class, and provides a set of
# helper functions for test classes to use.
#
# ##############################################################################
extends "res://addons/gut/test.gd"

func assert_asset_location_eq_dict(asset_location: PlayAssetLocation, dict: Dictionary):
	assert_eq(dict.size(), 3)
	assert_eq(asset_location.get_offset(), dict["offset"])
	assert_eq(asset_location.get_path(), dict["path"])
	assert_eq(asset_location.get_size(), dict["size"])

func assert_asset_pack_location_eq_dict(asset_pack_location: PlayAssetPackLocation, dict: Dictionary):
	assert_eq(dict.size(), 3)
	assert_eq(asset_pack_location.get_assets_path(), dict["assetsPath"])
	assert_eq(asset_pack_location.get_storage_method(), dict["packStorageMethod"])
	assert_eq(asset_pack_location.get_path(), dict["path"])

func assert_asset_pack_state_eq_dict(asset_pack_state: PlayAssetPackState, dict: Dictionary):
	assert_eq(dict.size(), 6)
	assert_eq(asset_pack_state.get_name(), dict["name"])
	assert_eq(asset_pack_state.get_status(), dict["status"])
	assert_eq(asset_pack_state.get_error_code(), dict["errorCode"])
	assert_eq(asset_pack_state.get_bytes_downloaded(), dict["bytesDownloaded"])
	assert_eq(asset_pack_state.get_total_bytes_to_download(), dict["totalBytesToDownload"])
	assert_eq(asset_pack_state.get_transfer_progress_percentage(), dict["transferProgressPercentage"])

func assert_asset_pack_states_eq_dict(asset_pack_states: PlayAssetPackStates, dict: Dictionary):
	assert_eq(dict.size(), 2)
	assert_eq(asset_pack_states.get_total_bytes(), dict["totalBytes"])
	# tests get_pack_states()
	var pack_states: Dictionary = asset_pack_states.get_pack_states()
	assert_eq(pack_states.size(), dict["packStates"].size())
	for key in dict["packStates"].keys():
		assert_true(key in pack_states)
		assert_asset_pack_state_eq_dict(pack_states[key], dict["packStates"][key])
		# tests get_pack_state()
		assert_asset_pack_state_eq_dict(asset_pack_states.get_pack_state(key), dict["packStates"][key])

func create_mock_asset_pack_states_dict() -> Dictionary:
	var pack_1_dict = {
		"name": "assetPack1", 
		"status": PlayAssetPackManager.AssetPackStatus.DOWNLOADING, 
		"errorCode": PlayAssetPackManager.AssetPackErrorCode.NO_ERROR,
		"bytesDownloaded": 562,
		"totalBytesToDownload": 1337,
		"transferProgressPercentage": 42
	}
	
	var pack_2_dict = {
		"name": "assetPack2", 
		"status": PlayAssetPackManager.AssetPackStatus.DOWNLOADING, 
		"errorCode": PlayAssetPackManager.AssetPackErrorCode.NO_ERROR,
		"bytesDownloaded": 0,
		"totalBytesToDownload": 4096,
		"transferProgressPercentage": 0
	}
	
	var test_dict = {
		"totalBytes": 5433,
		"packStates": {
			"assetPack1": pack_1_dict,
			"assetPack2": pack_2_dict
		}
	}
	
	return test_dict

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

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------
func assert_asset_location_eq_dict(asset_location: PlayAssetLocation, dict: Dictionary):
	assert_eq(dict.size(), 3)
	assert_eq(asset_location.get_offset(), dict[PlayAssetLocation._OFFSET_KEY])
	assert_eq(asset_location.get_path(), dict[PlayAssetLocation._PATH_KEY])
	assert_eq(asset_location.get_size(), dict[PlayAssetLocation._SIZE_KEY])

func assert_asset_pack_location_eq_dict(asset_pack_location: PlayAssetPackLocation, dict: Dictionary):
	assert_eq(dict.size(), 3)
	assert_eq(asset_pack_location.get_assets_path(), dict[PlayAssetPackLocation._ASSETS_PATH_KEY])
	assert_eq(asset_pack_location.get_storage_method(), dict[PlayAssetPackLocation._PACK_STORAGE_METHOD_KEY])
	assert_eq(asset_pack_location.get_path(), dict[PlayAssetLocation._PATH_KEY])

func assert_asset_pack_locations_eq_dict(asset_pack_locations: Dictionary, dict: Dictionary):
	assert_eq(asset_pack_locations.size(), dict.size())
	for key in asset_pack_locations.keys():
		assert_asset_pack_location_eq_dict(asset_pack_locations[key], dict[key])

func assert_asset_pack_state_eq_dict(asset_pack_state: PlayAssetPackState, dict: Dictionary):
	assert_eq(dict.size(), 6)
	assert_eq(asset_pack_state.get_name(), dict[PlayAssetPackState._NAME_KEY])
	assert_eq(asset_pack_state.get_status(), dict[PlayAssetPackState._STATUS_KEY])
	assert_eq(asset_pack_state.get_error_code(), dict[PlayAssetPackState._ERROR_CODE_KEY])
	assert_eq(asset_pack_state.get_bytes_downloaded(), dict[PlayAssetPackState._BYTES_DOWNLOADED_KEY])
	assert_eq(asset_pack_state.get_total_bytes_to_download(),\
		 dict[PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY])
	assert_eq(asset_pack_state.get_transfer_progress_percentage(),\
		 dict[PlayAssetPackState._TRANSFER_PROGRESS_PERCENTAGE_KEY])

func assert_asset_pack_states_eq_dict(asset_pack_states: PlayAssetPackStates, dict: Dictionary):
	assert_eq(dict.size(), 2)
	assert_eq(asset_pack_states.get_total_bytes(), dict[PlayAssetPackStates._TOTAL_BYTES_KEY])
	# tests get_pack_states()
	var pack_states: Dictionary = asset_pack_states.get_pack_states()
	assert_eq(pack_states.size(), dict[PlayAssetPackStates._PACK_STATES_KEY].size())
	for key in dict[PlayAssetPackStates._PACK_STATES_KEY].keys():
		assert_true(key in pack_states)
		assert_asset_pack_state_eq_dict(pack_states[key], dict[PlayAssetPackStates._PACK_STATES_KEY][key])

func assert_asset_pack_exception_eq_dict(exception: PlayAssetPackException, dict: Dictionary):
	assert_eq(dict.size(), 3)
	assert_eq(exception.get_type(), dict[PlayAssetPackException._TYPE_KEY])
	assert_eq(exception.get_message(), dict[PlayAssetPackException._MESSAGE_KEY])
	assert_eq(exception.get_error_code(), dict[PlayAssetPackException._ERROR_CODE_KEY])

func create_mock_asset_pack_states_dict() -> Dictionary:
	var pack_1_dict = {
		PlayAssetPackState._NAME_KEY: "assetPack1", 
		PlayAssetPackState._STATUS_KEY: PlayAssetPackManager.AssetPackStatus.DOWNLOADING, 
		PlayAssetPackState._ERROR_CODE_KEY: PlayAssetPackManager.AssetPackErrorCode.NO_ERROR,
		PlayAssetPackState._BYTES_DOWNLOADED_KEY: 562,
		PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY: 1337,
		PlayAssetPackState._TRANSFER_PROGRESS_PERCENTAGE_KEY: 42
	}
	
	var pack_2_dict = {
		PlayAssetPackState._NAME_KEY: "assetPack2", 
		PlayAssetPackState._STATUS_KEY: PlayAssetPackManager.AssetPackStatus.DOWNLOADING, 
		PlayAssetPackState._ERROR_CODE_KEY: PlayAssetPackManager.AssetPackErrorCode.NO_ERROR,
		PlayAssetPackState._BYTES_DOWNLOADED_KEY: 0,
		PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY: 4096,
		PlayAssetPackState._TRANSFER_PROGRESS_PERCENTAGE_KEY: 0
	}
	
	var test_dict = {
		PlayAssetPackStates._TOTAL_BYTES_KEY: 5433,
		PlayAssetPackStates._PACK_STATES_KEY: {
			"assetPack1": pack_1_dict,
			"assetPack2": pack_2_dict
		}
	}
	
	return test_dict

func create_mock_asset_locations_dict() -> Dictionary:
	var pack_location_1_dict = {
		PlayAssetPackLocation._ASSETS_PATH_KEY: "/assetsPath/", 
		PlayAssetPackLocation._PACK_STORAGE_METHOD_KEY: PlayAssetPackManager.AssetPackStorageMethod.STORAGE_FILES, 
		PlayAssetLocation._PATH_KEY: "/path/"
	}

	var pack_location_2_dict = {
		PlayAssetPackLocation._ASSETS_PATH_KEY: "/assetsPath2/", 
		PlayAssetPackLocation._PACK_STORAGE_METHOD_KEY: PlayAssetPackManager.AssetPackStorageMethod.STORAGE_FILES, 
		PlayAssetLocation._PATH_KEY: "/path2/"
	}
	
	var test_dict = {
		"assetLocation1": pack_location_1_dict,
		"assetLocation2": pack_location_2_dict,
	}
	
	return test_dict

func create_mock_asset_pack_state_with_status_dict(pack_name : String, status : int):
	return {
		PlayAssetPackState._NAME_KEY: pack_name, 
		PlayAssetPackState._STATUS_KEY: status, 
		PlayAssetPackState._ERROR_CODE_KEY: PlayAssetPackManager.AssetPackErrorCode.NO_ERROR,
		PlayAssetPackState._BYTES_DOWNLOADED_KEY: 0,
		PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY: 4096,
		PlayAssetPackState._TRANSFER_PROGRESS_PERCENTAGE_KEY: 0
	}


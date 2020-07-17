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
extends "res://test/test_helper/base_test_class.gd"

func test_play_asset_pack_state_valid():
	var test_dict = {
		PlayAssetPackState._NAME_KEY: "assetPack", 
		PlayAssetPackState._STATUS_KEY: PlayAssetPackManager.AssetPackStatus.DOWNLOADING, 
		PlayAssetPackState._ERROR_CODE_KEY: PlayAssetPackManager.AssetPackErrorCode.NO_ERROR,
		PlayAssetPackState._BYTES_DOWNLOADED_KEY: 562,
		PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY: 1337,
		PlayAssetPackState._TRANSFER_PROGRESS_PERCENTAGE_KEY: 42
	}
	var test_object = PlayAssetPackState.new(test_dict)
	
	assert_asset_pack_state_eq_dict(test_object, test_dict)

func test_play_asset_pack_state_deepcopy():
	var test_dict = {
		PlayAssetPackState._NAME_KEY: "assetPack", 
		PlayAssetPackState._STATUS_KEY: PlayAssetPackManager.AssetPackStatus.DOWNLOADING, 
		PlayAssetPackState._ERROR_CODE_KEY: PlayAssetPackManager.AssetPackErrorCode.NO_ERROR,
		PlayAssetPackState._BYTES_DOWNLOADED_KEY: 562,
		PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY: 1337,
		PlayAssetPackState._TRANSFER_PROGRESS_PERCENTAGE_KEY: 42
	}
	var expected_dict = test_dict.duplicate()
	var test_object = PlayAssetPackState.new(test_dict)
	
	# alter the dictionary value passed to the constructor
	# object created should not be changed since we are doing deepcopy
	assert_asset_pack_state_eq_dict(test_object, expected_dict)

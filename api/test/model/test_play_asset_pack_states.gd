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
extends "res://addons/gut/test.gd"

func test_play_asset_pack_states_valid():
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
	
	var test_object = PlayAssetPackStates.new(test_dict)
	print("-------------------------------------------------------")
	print(test_object.get_pack_states())
	assert_eq(test_object.get_total_bytes(), 5433)
	
	var test_pack_states = test_object.get_pack_states()
	assert_eq(test_pack_states.size(), 2)
	
	assert_true("assetPack1" in test_pack_states)
	var test_pack1 : PlayAssetPackState = test_pack_states["assetPack1"]
	assert_eq(test_pack1.get_name(), "assetPack1")
	assert_eq(test_pack1.get_status(), PlayAssetPackManager.AssetPackStatus.DOWNLOADING)
	assert_eq(test_pack1.get_error_code(), PlayAssetPackManager.AssetPackErrorCode.NO_ERROR)
	assert_eq(test_pack1.get_bytes_downloaded(), 562)
	assert_eq(test_pack1.get_total_bytes_to_download(), 1337)
	assert_eq(test_pack1.get_transfer_progress_percentage(), 42)

	assert_true("assetPack2" in test_pack_states)
	var test_pack2 : PlayAssetPackState = test_pack_states["assetPack2"]
	assert_eq(test_pack2.get_name(), "assetPack2")
	assert_eq(test_pack2.get_status(), PlayAssetPackManager.AssetPackStatus.DOWNLOADING)
	assert_eq(test_pack2.get_error_code(), PlayAssetPackManager.AssetPackErrorCode.NO_ERROR)
	assert_eq(test_pack2.get_bytes_downloaded(), 0)
	assert_eq(test_pack2.get_total_bytes_to_download(), 4096)
	assert_eq(test_pack2.get_transfer_progress_percentage(), 0)

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

func create_play_asset_pack_manager(mock_plugin):
	var test_object = partial_double("res://src/play_asset_pack_manager.gd").new()
	stub(test_object, "_initialize_plugin").to_return(mock_plugin)
	test_object._initialize()
	return test_object

func test_get_asset_location_valid():
	var test_pack = "testPack"
	var test_path = "/path/"
	var return_dict = {
		PlayAssetLocation._OFFSET_KEY: 42, 
		PlayAssetLocation._PATH_KEY: "path/", 
		PlayAssetLocation._SIZE_KEY: 100
	}
	
	var mock_plugin = FakeAndroidPlugin.new()
	mock_plugin.add_asset_location(test_pack, test_path, return_dict)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : PlayAssetLocation = test_object.get_asset_location(test_pack, test_path)
	
	assert_asset_location_eq_dict(test_result, return_dict)

func test_get_asset_location_not_exist():
	var test_pack = "testPack"
	var test_path = "/path/"
	var pack_dict = {
		PlayAssetLocation._OFFSET_KEY: 42, 
		PlayAssetLocation._PATH_KEY: "path/", 
		PlayAssetLocation._SIZE_KEY: 100
	}
	
	var mock_plugin = FakeAndroidPlugin.new()
	mock_plugin.add_asset_location(test_pack, test_path, pack_dict)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : PlayAssetLocation = test_object.get_asset_location(test_pack, "/otherPath/")
	
	assert_eq(test_result, null)

func test_get_asset_pack_location_valid():
	var test_pack = "testPack"
	var return_dict = {
		PlayAssetPackLocation._ASSETS_PATH_KEY: "/assetsPath/", 
		PlayAssetPackLocation._PACK_STORAGE_METHOD_KEY: PlayAssetPackManager.AssetPackStorageMethod.STORAGE_FILES, 
		PlayAssetLocation._PATH_KEY: "/path/"
	}
	
	var mock_plugin = FakeAndroidPlugin.new()
	mock_plugin.add_asset_pack_location(test_pack, return_dict)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : PlayAssetPackLocation = test_object.get_pack_location(test_pack)
	
	assert_asset_pack_location_eq_dict(test_result, return_dict)

func test_get_asset_pack_location_not_exist():
	var test_pack = "testPack"
	var return_dict = {
		PlayAssetPackLocation._ASSETS_PATH_KEY: "/assetsPath/", 
		PlayAssetPackLocation._PACK_STORAGE_METHOD_KEY: PlayAssetPackManager.AssetPackStorageMethod.STORAGE_FILES, 
		PlayAssetLocation._PATH_KEY: "/path/"
	}
	
	var mock_plugin = FakeAndroidPlugin.new()
	mock_plugin.add_asset_pack_location(test_pack, return_dict)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : PlayAssetPackLocation = test_object.get_pack_location("notExistPack")
	
	assert_eq(test_result, null)

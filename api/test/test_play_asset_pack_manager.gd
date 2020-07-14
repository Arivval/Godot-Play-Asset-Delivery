"""
	Copyright 2020 Google LLC

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		https://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
"""

extends "res://addons/gut/test.gd"

func create_play_asset_pack_manager(mock_plugin):
	var test_object = partial_double("res://src/play_asset_pack_manager.gd").new()
	stub(test_object, "_initialize_plugin").to_return(mock_plugin)
	test_object._initialize()
	return test_object

func test_get_pack_location_valid():
	var test_query = "test pack"
	var return_dict = {"offset": 42, "path": "path/", "size": 100}
	var mock_plugin = double(AndroidPluginMock).new()
	stub(mock_plugin, "getPackLocation").to_return(return_dict).when_passed(test_query)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : PlayAssetLocation = test_object.get_pack_location(test_query)
	assert_eq(test_result.get_offset(), 42)
	assert_eq(test_result.get_path(), "path/")
	assert_eq(test_result.get_size(), 100)

func test_get_pack_location_not_exist():
	var test_query = "test pack"
	var return_dict = null
	var mock_plugin = double(AndroidPluginMock).new()
	stub(mock_plugin, "getPackLocation").to_return(return_dict).when_passed(test_query)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : PlayAssetLocation = test_object.get_pack_location(test_query)
	assert_eq(test_result, null)


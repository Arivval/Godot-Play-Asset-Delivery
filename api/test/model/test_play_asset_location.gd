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

func test_play_asset_location_valid():
	var test_dict = {"offset": 42, "path": "path/", "size": 100}
	var test_object = PlayAssetLocation.new(test_dict)
	
	assert_eq(test_object.get_offset(), 42)
	assert_eq(test_object.get_path(), "path/")
	assert_eq(test_object.get_size(), 100)

func test_play_asset_location_deepcopy():
	var test_dict = {"offset": 42, "path": "path/", "size": 100}
	var test_object = PlayAssetLocation.new(test_dict)
	
	# alter the dictionary value passed to the constructor
	# object created should not be changed since we are doing deepcopy
	test_dict["offset"] = 0
	
	assert_eq(test_object.get_offset(), 42)
	assert_eq(test_object.get_path(), "path/")
	assert_eq(test_object.get_size(), 100)

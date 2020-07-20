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

func test_play_asset_pack_exception_valid():
	var test_dict = {
		PlayAssetPackException._TYPE_KEY: "java.lang.Exception", 
		PlayAssetPackException._MESSAGE_KEY: "Just an usual exception", 
		PlayAssetPackException._ERROR_CODE_KEY: -100
	}
	var test_object = PlayAssetPackException.new(test_dict)
	assert_asset_pack_exception_eq_dict(test_object, test_dict)

func test_play_asset_location_deepcopy():
	var test_dict = {
		PlayAssetPackException._TYPE_KEY: "java.lang.Exception", 
		PlayAssetPackException._MESSAGE_KEY: "Just an usual exception", 
		PlayAssetPackException._ERROR_CODE_KEY: -100
	}
	var expected_dict = test_dict.duplicate()
	var test_object = PlayAssetPackException.new(test_dict)
	
	# alter the dictionary value passed to the constructor
	# object created should not be changed since we are doing deepcopy
	test_dict[PlayAssetPackException._ERROR_CODE_KEY] = 0
	
	assert_asset_pack_exception_eq_dict(test_object, expected_dict)

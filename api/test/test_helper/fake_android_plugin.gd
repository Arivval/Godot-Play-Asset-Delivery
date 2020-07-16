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
# Class that creates a fake PlayAssetDelivery Android plugin, mocking the 
# behaviour of the Java API. Provides helper functions that allow us to configure
# returned object and side effects of PlayAssetDelivery plugin calls.
#
# ##############################################################################
class_name FakeAndroidPlugin
extends Object

var _asset_location_store : Dictionary
var _asset_pack_location_store : Dictionary

func _init():
	_asset_location_store = Dictionary()
	_asset_pack_location_store = Dictionary()

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------
func add_asset_location(pack_name : String, asset_path : String, asset_location_dict : Dictionary):
	_asset_location_store[[pack_name , asset_path]] = asset_location_dict

func remove_asset_location(pack_name : String, asset_path : String):
	_asset_location_store.erase([pack_name , asset_path])

func clear_asset_location_store():
	_asset_location_store.clear()

func add_asset_pack_location(pack_name : String, asset_pack_location_dict : Dictionary):
	_asset_pack_location_store[pack_name] = asset_pack_location_dict

func remove_asset_pack_location(pack_name : String):
	_asset_pack_location_store.erase(pack_name)

func clear_asset_pack_location_store():
	_asset_pack_location_store.clear()

# -----------------------------------------------------------------------------
# Mock Functions
# -----------------------------------------------------------------------------
func getAssetLocation(pack_name : String, asset_path : String):
	var dict_key = [pack_name , asset_path]
	if dict_key in _asset_location_store:
		return _asset_location_store[dict_key]
	return null

func getPackLocation(pack_name : String):
	if pack_name in _asset_pack_location_store:
		return _asset_pack_location_store[pack_name]
	return null

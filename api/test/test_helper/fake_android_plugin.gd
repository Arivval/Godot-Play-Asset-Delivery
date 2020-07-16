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
# return this object as the updated AssetPackState when cancel() is called
var _asset_pack_state_on_cancel : Dictionary
# change this boolean so we can simulate the situation where the user cancels a nonexistent pack
var on_cancel_return_not_found : bool = false

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

func set_asset_pack_locations(asset_pack_locations_dict : Dictionary):
	_asset_pack_location_store = asset_pack_locations_dict

func set_asset_pack_state_on_cancel(asset_pack_state_dict : Dictionary):
	_asset_pack_state_on_cancel = asset_pack_state_dict

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

func getPackLocations():
	return _asset_pack_location_store

# -----------------------------------------------------------------------------
# If on_cancel_return_not_found is false, returns an AssetPackStates object 
# where all updated AssetPackState will be instantiated by duplicating
# _asset_pack_state_on_cancel. Else returns an Dictionary that simulates 
# the situation where user cancels a nonexisting asset pack.
# -----------------------------------------------------------------------------
func cancel(pack_names : Array):
	if on_cancel_return_not_found:
		var ret_dict = {
		PlayAssetPackStates._TOTAL_BYTES_KEY: 0,
		PlayAssetPackStates._PACK_STATES_KEY: {}
	}
		return ret_dict
		
	var pack_states = Dictionary()
	var total_bytes = 0
	for pack_name in pack_names:
		var updated_asset_pack_state : Dictionary = _asset_pack_state_on_cancel.duplicate()
		# ensure the returned dict is not corrupted by syncing pack names
		updated_asset_pack_state[PlayAssetPackState._NAME_KEY] = pack_name
		pack_states[pack_name] = updated_asset_pack_state
		total_bytes += updated_asset_pack_state[PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY]
	
	var ret_dict = {
		PlayAssetPackStates._TOTAL_BYTES_KEY: total_bytes,
		PlayAssetPackStates._PACK_STATES_KEY: pack_states
	}
	
	return ret_dict
 

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

var _asset_pack_states_store : Dictionary

func _init():
	_asset_location_store = Dictionary()
	_asset_pack_location_store = Dictionary()
	
	_asset_pack_states_store = {
		PlayAssetPackStates._TOTAL_BYTES_KEY: 0,
		PlayAssetPackStates._PACK_STATES_KEY: {}
	}

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

func set_asset_pack_states_store(asset_pack_states_dict : Dictionary):
	_asset_pack_states_store = asset_pack_states_dict

func clear_asset_pack_states_store():
	_asset_pack_states_store = {
		PlayAssetPackStates._TOTAL_BYTES_KEY: 0,
		PlayAssetPackStates._PACK_STATES_KEY: {}
	}

func add_asset_pack_state(asset_pack_state_dict : Dictionary):
	_asset_pack_states_store[PlayAssetPackStates._TOTAL_BYTES_KEY] += \
		asset_pack_state_dict[PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY]
	var pack_name = asset_pack_state_dict[PlayAssetPackState._NAME_KEY]
	_asset_pack_states_store[PlayAssetPackStates._PACK_STATES_KEY][pack_name] = asset_pack_state_dict

func remove_asset_pack_state(pack_name : String):
	if pack_name in _asset_pack_states_store[PlayAssetPackStates._PACK_STATES_KEY]:
		var pack_state = _asset_pack_states_store[PlayAssetPackStates._PACK_STATES_KEY][pack_name]
		var pack_size = pack_state[PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY]
		# update totalBytes
		_asset_pack_states_store[PlayAssetPackStates._TOTAL_BYTES_KEY] -= pack_size
		_asset_pack_states_store[PlayAssetPackStates._PACK_STATES_KEY].erase(pack_name)

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
# Simulates the cancel() function in PlayAssetDelivery Android plugin. Iterate
# through all AssetPackState within _asset_pack_states_store and return the
# updated states.
# -----------------------------------------------------------------------------
func cancel(pack_names : Array):
	var return_asset_pack_states = {
		PlayAssetPackStates._TOTAL_BYTES_KEY: 0,
		PlayAssetPackStates._PACK_STATES_KEY: {}
	}

	# iterate through all pack_names, if they exist in _asset_pack_states_store, try cancel them
	for pack_name in pack_names:
		var current_asset_pack_states_dict = _asset_pack_states_store[PlayAssetPackStates._PACK_STATES_KEY]
		if pack_name in current_asset_pack_states_dict:
			# Only active downloads can be canceled
			var current_asset_pack_dict = current_asset_pack_states_dict[pack_name]
			var current_asset_pack_status = current_asset_pack_dict[PlayAssetPackState._STATUS_KEY]
			if current_asset_pack_status == PlayAssetPackManager.AssetPackStatus.DOWNLOADING:
				current_asset_pack_dict[PlayAssetPackState._STATUS_KEY] = \
					PlayAssetPackManager.AssetPackStatus.CANCELED
			
			# append resulting state to return_asset_pack_states
			var current_asset_pack_size = current_asset_pack_dict[PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY]
			return_asset_pack_states[PlayAssetPackStates._TOTAL_BYTES_KEY] += current_asset_pack_size
			return_asset_pack_states[PlayAssetPackStates._PACK_STATES_KEY][pack_name] = current_asset_pack_dict

	return return_asset_pack_states

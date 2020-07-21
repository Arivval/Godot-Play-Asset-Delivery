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

signal removePackSuccess
signal removePackError
signal showCellularDataConfirmationSuccess
signal showCellularDataConfirmationError

var _asset_location_store : Dictionary
var _asset_pack_location_store : Dictionary

var _asset_pack_states_store : Dictionary

var _show_confirmation_thread : Thread
var _show_confirmation_success : bool
var _show_confirmation_result : int
var _show_confirmation_error : Dictionary

var _remove_pack_thread : Thread
var _remove_pack_success : bool
var _remove_pack_error : Dictionary

func _init():
	_asset_location_store = Dictionary()
	_asset_pack_location_store = Dictionary()
	
	_asset_pack_states_store = _create_empty_asset_pack_states()

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------
func _create_empty_asset_pack_states() -> Dictionary:
	return {
		PlayAssetPackStates._TOTAL_BYTES_KEY: 0,
		PlayAssetPackStates._PACK_STATES_KEY: {}
	}

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
	_asset_pack_states_store = _create_empty_asset_pack_states()

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

func set_show_confirmation_response(success : bool, result : int, error : Dictionary):
	_show_confirmation_success = success
	_show_confirmation_result = result
	_show_confirmation_error = error

func set_remove_pack_response(success : bool, error : Dictionary):
	_remove_pack_success = success
	_remove_pack_error = error

# -----------------------------------------------------------------------------
# Helper function that emits signal from another thread with latency so we 
# have time to connect to that signal on main thread for testing.
# -----------------------------------------------------------------------------
func emit_delayed_signal_helper(args : Array):
	# Delay this thread by 100 milliseconds, allowing us to connect/yield to signal in time.
	OS.delay_msec(100)
	# Since all the signals released by the plugin contains either 2 or 3 arguments, we only need
	# to handle 2 cases.
	if args.size() == 2:
		emit_signal(args[0], args[1])
	if args.size() == 3:
		emit_signal(args[0], args[1], args[2])

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
	var return_asset_pack_states = _create_empty_asset_pack_states()

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

# -----------------------------------------------------------------------------
# Simulates the showCellularDataConfirmation() function in PlayAssetDelivery 
# Android plugin. Emits signal with arguments configured using 
# set_show_confirmation_response().
# -----------------------------------------------------------------------------
func showCellularDataConfirmation(signal_id : int):
	# use multithreading to call emit_delayed_signal_helper() to emit signal with delay since Godot's main
	# thread is blocking
	_show_confirmation_thread = Thread.new()
	if _show_confirmation_success:
		var thread_args = ["showCellularDataConfirmationSuccess", _show_confirmation_result, signal_id]
		_show_confirmation_thread.start(self, "emit_delayed_signal_helper", thread_args)
	else:
		var thread_args = ["showCellularDataConfirmationError", _show_confirmation_error, signal_id]
		_show_confirmation_thread.start(self, "emit_delayed_signal_helper", thread_args)

# -----------------------------------------------------------------------------
# Simulates the removePack() function in PlayAssetDelivery Android plugin. 
# Emits signal with arguments configured using set_remove_pack_response().
# -----------------------------------------------------------------------------
func removePack(pack_name : String, signal_id : int):
	# use multithreading to call emit_delayed_signal_helper() to emit signal with delay since Godot's main
	# thread is blocking
	_remove_pack_thread = Thread.new()
	if _remove_pack_success:
		var thread_args = ["removePackSuccess", signal_id]
		_remove_pack_thread.start(self, "emit_delayed_signal_helper", thread_args)
	else:
		var thread_args = ["removePackError", _remove_pack_error, signal_id]
		_remove_pack_thread.start(self, "emit_delayed_signal_helper", thread_args)

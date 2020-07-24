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
# returned object and side effects of PlayAssetDelivery plugin calls. Some of 
# the functions and signals in this class will use camelCasing as the naming
# convention, since they are mocking functions and signals written in Java.
#
# ##############################################################################
class_name FakeAndroidPlugin
extends Object

signal assetPackStateUpdated(resultDictionary)
signal fetchSuccess(resultDictionary, signalID)
signal fetchError(exceptionDictionary, signalID)
signal getPackStatesSuccess(resultDictionary, signalID)
signal getPackStatesError(exceptionDictionary, signalID)
signal removePackSuccess(signalID)
signal removePackError(exceptionDictionary, signalID)
signal showCellularDataConfirmationSuccess(resultInt, signalID)
signal showCellularDataConfirmationError(exceptionDictionary, signalID)

const _EMIT_DELAYED_SIGNAL_FUNCTION : String = "emit_delayed_signal"

var _asset_location_store : Dictionary
var _asset_pack_location_store : Dictionary

var _asset_pack_states_store : Dictionary

var _fetch_info : FakePackStatesInfo
var _get_pack_states_info : FakePackStatesInfo
var _cellular_confirmation_info : FakeCellularConfirmationInfo
var _remove_pack_info : FakeRemovePackInfo

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

func update_asset_pack_state(asset_pack_state_dict : Dictionary):
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

func set_fetch_info(signal_info : FakePackStatesInfo):
	_fetch_info = signal_info

func set_get_pack_states_info(signal_info : FakePackStatesInfo):
	_get_pack_states_info = signal_info

func set_cellular_confirmation_info(signal_info : FakeCellularConfirmationInfo):
	_cellular_confirmation_info = signal_info

func set_remove_pack_info(signal_info : FakeRemovePackInfo):
	_remove_pack_info = signal_info

# -----------------------------------------------------------------------------
# Helper function that emits signal from another thread with latency so we 
# have time to connect to that signal on main thread for testing.
# -----------------------------------------------------------------------------
func emit_delayed_signal(args : Array):
	# Delay this thread by 100 milliseconds, allowing us to connect/yield to signal in time.
	OS.delay_msec(100)
	# Since all the signals released by the plugin contains either 2 or 3 arguments, we only need
	# to handle 2 cases.
	if args.size() == 2:
		emit_signal(args[0], args[1])
	if args.size() == 3:
		emit_signal(args[0], args[1], args[2])

# -----------------------------------------------------------------------------
# Helper function that emits a mocked assetPackStateUpdated signal, with result
# specified by _asset_pack_state_updated_info.
# -----------------------------------------------------------------------------
func trigger_asset_pack_state_updated_signal(_asset_pack_state_updated_info : FakePackStateInfo):
	# update _asset_pack_states_store with updated state
	update_asset_pack_state(_asset_pack_state_updated_info.result)
	_asset_pack_state_updated_info.thread = Thread.new()
	var thread_args = ["assetPackStateUpdated", _asset_pack_state_updated_info.result]
	_asset_pack_state_updated_info.thread.start(self, _EMIT_DELAYED_SIGNAL_FUNCTION, thread_args)

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
# Simulates the fetch() function in PlayAssetDelivery Android plugin. 
# Emits signal with arguments configured using set_fetch_info().
# -----------------------------------------------------------------------------
func fetch(pack_names : Array, signal_id : int):
	_fetch_info.thread = Thread.new()
	if _fetch_info.success:
		# update _asset_pack_states_store if pack_name is valid, so that cancel() can work correctly
		var pack_states = _fetch_info.result[PlayAssetPackStates._PACK_STATES_KEY]
		if pack_states.has(pack_names[0]):
			var asset_pack_state = pack_states[pack_names[0]]
			update_asset_pack_state(asset_pack_state)
		
		var thread_args = ["fetchSuccess", _fetch_info.result, signal_id]
		_fetch_info.thread.start(self, _EMIT_DELAYED_SIGNAL_FUNCTION, thread_args)
	else:
		var thread_args = ["fetchError", _fetch_info.error, signal_id]
		_fetch_info.thread.start(self, _EMIT_DELAYED_SIGNAL_FUNCTION, thread_args)

# -----------------------------------------------------------------------------
# Simulates the getPackStates() function in PlayAssetDelivery Android plugin. 
# Emits signal with arguments configured using set_get_pack_states_info().
# -----------------------------------------------------------------------------
func getPackStates(pack_names : Array, signal_id : int):
	_get_pack_states_info.thread = Thread.new()
	if _get_pack_states_info.success:
		var thread_args = ["getPackStatesSuccess", _get_pack_states_info.result, signal_id]
		_get_pack_states_info.thread.start(self, _EMIT_DELAYED_SIGNAL_FUNCTION, thread_args)
	else:
		var thread_args = ["getPackStatesError", _get_pack_states_info.error, signal_id]
		_get_pack_states_info.thread.start(self, _EMIT_DELAYED_SIGNAL_FUNCTION, thread_args)

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
				# emit asset_pack_state_updated signal
				var signal_info = FakePackStateInfo.new(current_asset_pack_dict)
				trigger_asset_pack_state_updated_signal(signal_info)
				
			# append resulting state to return_asset_pack_states
			var current_asset_pack_size = current_asset_pack_dict[PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY]
			return_asset_pack_states[PlayAssetPackStates._TOTAL_BYTES_KEY] += current_asset_pack_size
			return_asset_pack_states[PlayAssetPackStates._PACK_STATES_KEY][pack_name] = current_asset_pack_dict

	return return_asset_pack_states

# -----------------------------------------------------------------------------
# Simulates the showCellularDataConfirmation() function in PlayAssetDelivery 
# Android plugin. Emits signal with arguments configured using
# set_cellular_confirmation_info().
# -----------------------------------------------------------------------------
func showCellularDataConfirmation(signal_id : int):
	# use multithreading to call emit_delayed_signal() to emit signal with delay since Godot's main
	# thread is blocking
	_cellular_confirmation_info.thread = Thread.new()

	if _cellular_confirmation_info.success:
		var thread_args = ["showCellularDataConfirmationSuccess", _cellular_confirmation_info.result, signal_id]
		_cellular_confirmation_info.thread.start(self, _EMIT_DELAYED_SIGNAL_FUNCTION, thread_args)
	else:
		var thread_args = ["showCellularDataConfirmationError", _cellular_confirmation_info.error, signal_id]
		_cellular_confirmation_info.thread.start(self, _EMIT_DELAYED_SIGNAL_FUNCTION, thread_args)

# -----------------------------------------------------------------------------
# Simulates the removePack() function in PlayAssetDelivery Android plugin. 
# Emits signal with arguments configured using set_remove_pack_info().
# -----------------------------------------------------------------------------
func removePack(pack_name : String, signal_id : int):
	# use multithreading to call emit_delayed_signal() to emit signal with delay since Godot's main
	# thread is blocking
	_remove_pack_info.thread = Thread.new()
	if _remove_pack_info.success:
		var thread_args = ["removePackSuccess", signal_id]
		_remove_pack_info.thread.start(self, _EMIT_DELAYED_SIGNAL_FUNCTION, thread_args)
	else:
		var thread_args = ["removePackError", _remove_pack_info.error, signal_id]
		_remove_pack_info.thread.start(self, _EMIT_DELAYED_SIGNAL_FUNCTION, thread_args)

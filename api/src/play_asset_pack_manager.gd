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
# Singleton class that initializes the PlayAssetDelivery Android plugin and 
# manages downloads of asset packs. Recommended to autoload this script by
# modifying the configurations in Project -> Project Settings -> AutoLoad.
# Functions and signals provided by the Android plugin will use camelCasing as 
# the naming convention, since the plugin is written in Java.
#
# ##############################################################################
# Suppress unused_signal warning because Godot cannot detect signal usage when 
# we call emit_signal() using call_deferred().
# warning-ignore:unused_signal
extends Node
# -----------------------------------------------------------------------------
# Emits state_updated(pack_name, state) global signal upon any asset pack's 
# state update.
# 	pack_name : String name of the pack
#	state: PlayAssetPackState object of the updated state
# -----------------------------------------------------------------------------
signal state_updated(pack_name, state)

var _plugin_singleton : Object
var _request_tracker : PlayAssetDeliveryRequestTracker

# Dictionary that stores the mapping of pack_name to relevant Request objects.
var _asset_pack_to_request_map : Dictionary	
var _play_asset_pack_manager_mutex : Mutex	

var _PACK_TERMINAL_STATES = [AssetPackStatus.CANCELED, AssetPackStatus.COMPLETED, AssetPackStatus.FAILED]

# -----------------------------------------------------------------------------
# Enums
# -----------------------------------------------------------------------------
enum AssetPackStorageMethod {
	STORAGE_FILES = 0,
	APK_ASSETS = 1
}

enum AssetPackStatus {	
	UNKNOWN = 0,
	PENDING = 1,
	DOWNLOADING = 2, 	
	TRANSFERRING = 3,
	COMPLETED = 4,
	FAILED = 5,
	CANCELED = 6,
	WAITING_FOR_WIFI = 7,
	NOT_INSTALLED = 8
}

enum AssetPackErrorCode {
	NO_ERROR = 0,
	APP_UNAVAILABLE = -1,
	PACK_UNAVAILABLE = -2,
	INVALID_REQUEST = -3,
	DOWNLOAD_NOT_FOUND = -4,
	API_NOT_AVAILABLE = -5, 	
	NETWORK_ERROR = -6,
	ACCESS_DENIED = -7,
	INSUFFICIENT_STORAGE = -10,
	PLAY_STORE_NOT_FOUND = -11,
	NETWORK_UNRESTRICTED = -12,
	INTERNAL_ERROR = -100
}

enum CellularDataConfirmationResult {
	RESULT_UNDEFINED = -2,
	RESULT_OK = -1,
	RESULT_CANCELED = 0
}

# -----------------------------------------------------------------------------
# Setup
# -----------------------------------------------------------------------------
func _ready():
	_initialize()

func _initialize():
	_plugin_singleton = _initialize_plugin()
	_connect_plugin_signals()
	_request_tracker = PlayAssetDeliveryRequestTracker.new()
	_play_asset_pack_manager_mutex = Mutex.new()

# -----------------------------------------------------------------------------
# Helper function that connects individual signals from the plugin to given
# callback function, logs related error.
# -----------------------------------------------------------------------------
func _connect_plugin_signal_helper(plugin_signal_name : String, callback_name : String):
	var connect_error_code = _plugin_singleton.connect(plugin_signal_name, self, callback_name)
	if connect_error_code != OK:
		push_error("Connecting plugin signal to function failed, error_code = " + str(connect_error_code))

# -----------------------------------------------------------------------------
# Connect signals, allowing signals emitted from the plugin to be correctly
# linked to functions in the front-facing API.
# -----------------------------------------------------------------------------
func _connect_plugin_signals():
	if _plugin_singleton != null:
		_connect_plugin_signal_helper("assetPackStateUpdated", "_route_asset_pack_state_updated")
		_connect_plugin_signal_helper("fetchSuccess", "_forward_fetch_success")
		_connect_plugin_signal_helper("fetchError", "_forward_fetch_error")
		_connect_plugin_signal_helper("getPackStatesSuccess", "_forward_get_pack_states_success")
		_connect_plugin_signal_helper("getPackStatesError", "_forward_get_pack_states_error")
		_connect_plugin_signal_helper("removePackSuccess", "_forward_remove_pack_success")
		_connect_plugin_signal_helper("removePackError", "_forward_remove_pack_error")
		_connect_plugin_signal_helper("showCellularDataConfirmationSuccess",\
			"_forward_show_cellular_data_confirmation_success")
		_connect_plugin_signal_helper("showCellularDataConfirmationError", \
			"_forward_show_cellular_data_confirmation_error")

# -----------------------------------------------------------------------------
# Returns the PlayAssetDelivery Android Plugin singleton, null if this plugin
# is unavailable
# -----------------------------------------------------------------------------
func _initialize_plugin() -> Object:
	if Engine.has_singleton("PlayAssetDelivery"):
		return Engine.get_singleton("PlayAssetDelivery")
	else:
		push_error("Android plugin singleton not found!")
		return null

# -----------------------------------------------------------------------------
# Helper function that synchronizes relevant request object's state upon 
# receiving assetPackStateUpdated signal.
# -----------------------------------------------------------------------------
func _route_asset_pack_state_updated(result : Dictionary):
	var updated_state : PlayAssetPackState = PlayAssetPackState.new(result)
	var pack_name = updated_state.get_name()
	var updated_status = updated_state.get_status()
	
	_play_asset_pack_manager_mutex.lock()	
	
	if _asset_pack_to_request_map.has(pack_name):
		var request = _asset_pack_to_request_map[pack_name]
		request.call_deferred("_on_state_updated", result)
		if updated_state.get_status() in _PACK_TERMINAL_STATES:
			_asset_pack_to_request_map.erase(pack_name)
	
	call_deferred("emit_signal", "state_updated", pack_name, updated_state)	
	
	_play_asset_pack_manager_mutex.unlock()

# -----------------------------------------------------------------------------
# Helper function called by request objects, to emit artifical state_updated signals.
# -----------------------------------------------------------------------------
func _forward_high_level_state_updated_signal(pack_name : String, state : Dictionary):
	var state_object : PlayAssetPackState = PlayAssetPackState.new(state)
	call_deferred("emit_signal", "state_updated", pack_name, state_object)


# -----------------------------------------------------------------------------
# Helper function used to unwrap pack_state from pack_states.
# -----------------------------------------------------------------------------
func _extract_pack_state_from_pack_states(result : Dictionary) -> PlayAssetPackState:
	var pack_states_object = PlayAssetPackStates.new(result).get_pack_states()
	return pack_states_object[pack_states_object.keys()[0]]

# -----------------------------------------------------------------------------
# Helper functions that forward signals emitted from the plugin
# -----------------------------------------------------------------------------
func _forward_fetch_success(result : Dictionary, signal_id : int):
	# Since fetchSuccess signal is always emitted after the global assetPackStateUpdated signal, we
	# don't need to call _on_fetch_success to update the state again.
	_request_tracker.unregister_request(signal_id)

func _forward_fetch_error(error : Dictionary, signal_id : int):
	var target_request : PlayAssetPackFetchRequest = _request_tracker.lookup_request(signal_id)
	target_request.call_deferred("_on_fetch_error", error)
	_request_tracker.unregister_request(signal_id)
	# emit status updated global signal
	var previous_state = target_request.get_state().to_dict()
	var pack_name = target_request.get_pack_name()
	previous_state[PlayAssetPackState._STATUS_KEY] = AssetPackStatus.FAILED
	previous_state[PlayAssetPackState._ERROR_CODE_KEY] = error[PlayAssetPackException._ERROR_CODE_KEY]
	_forward_high_level_state_updated_signal(pack_name, previous_state)
	
	_asset_pack_to_request_map.erase(pack_name)

func _forward_get_pack_states_success(result : Dictionary, signal_id : int):
	var target_request : PlayAssetPackStateRequest = _request_tracker.lookup_request(signal_id)
	target_request._on_get_asset_pack_state_success(result)
	_request_tracker.unregister_request(signal_id)

func _forward_get_pack_states_error(error : Dictionary, signal_id : int):
	var target_request : PlayAssetPackStateRequest = _request_tracker.lookup_request(signal_id)
	target_request._on_get_asset_pack_state_error(error)
	_request_tracker.unregister_request(signal_id)

func _forward_show_cellular_data_confirmation_success(result : int, signal_id : int):
	var target_request : PlayCellularDataConfirmationRequest = _request_tracker.lookup_request(signal_id)
	target_request._on_show_cellular_data_confirmation_success(result)
	_request_tracker.unregister_request(signal_id)

func _forward_show_cellular_data_confirmation_error(error : Dictionary, signal_id : int):
	var target_request : PlayCellularDataConfirmationRequest = _request_tracker.lookup_request(signal_id)
	target_request._on_show_cellular_data_confirmation_error(error)
	_request_tracker.unregister_request(signal_id)

func _forward_remove_pack_success(signal_id : int):
	var target_request : PlayAssetPackRemoveRequest = _request_tracker.lookup_request(signal_id)
	target_request._on_remove_pack_success()
	_request_tracker.unregister_request(signal_id)

func _forward_remove_pack_error(error : Dictionary, signal_id : int):
	var target_request : PlayAssetPackRemoveRequest = _request_tracker.lookup_request(signal_id)
	target_request._on_remove_pack_error(error)
	_request_tracker.unregister_request(signal_id)

# -----------------------------------------------------------------------------
# Returns the location of the specified asset in pack on the device, null if 
# the asset is not present in the given pack.
# -----------------------------------------------------------------------------
func get_asset_location(pack_name : String, asset_path : String) -> PlayAssetLocation:
	var query_dict = _plugin_singleton.getAssetLocation(pack_name, asset_path)
	if query_dict == null:
		return null
	return PlayAssetLocation.new(query_dict)

# -----------------------------------------------------------------------------
# Returns the location of the specified asset pack on the device, null if 
# this pack is not downloaded or is outdated.
# -----------------------------------------------------------------------------
func get_pack_location(pack_name : String) -> PlayAssetPackLocation:
	var query_dict = _plugin_singleton.getPackLocation(pack_name)
	if query_dict == null:
		return null
	return PlayAssetPackLocation.new(query_dict)

# -----------------------------------------------------------------------------
# Returns the location of all installed asset packs. More specifically, returns 
# a Dictionary, where for each entry, the key is the asset pack name and value 
# is the corresponding PlayAssetLocation object.
# -----------------------------------------------------------------------------
func get_pack_locations() -> Dictionary:
	var return_dict = Dictionary()
	var raw_dict = _plugin_singleton.getPackLocations()
	
	# convert inner dictionaries in raw_dict to PlayAssetLocation objects
	for key in raw_dict.keys():
		return_dict[key] = PlayAssetPackLocation.new(raw_dict[key])
	
	return return_dict

# -----------------------------------------------------------------------------
# Requests download state or details for given asset pack.
# 
# Do not use this method to determine whether an asset pack is downloaded. 
# Instead use get_pack_location(pack_name).
# -----------------------------------------------------------------------------
func get_asset_pack_state(pack_name: String) -> PlayAssetPackStateRequest:
	var return_request = PlayAssetPackStateRequest.new(pack_name)
	var signal_id = _request_tracker.register_request(return_request)
	_plugin_singleton.getPackStates([pack_name], signal_id)
	return return_request

# -----------------------------------------------------------------------------
# Requests to download the specified asset pack.
# -----------------------------------------------------------------------------
func fetch_asset_pack(pack_name: String) -> PlayAssetPackFetchRequest:
	# Update mapping of pack_name to request object, so that assetStateUpdated global signal	
	# can be correctly routed to this request object.
	var return_request : PlayAssetPackFetchRequest
	
	_play_asset_pack_manager_mutex.lock()
	if _asset_pack_to_request_map.has(pack_name):	
		return_request = _asset_pack_to_request_map[pack_name]
	else:
		return_request = PlayAssetPackFetchRequest.new(pack_name)
		var signal_id = _request_tracker.register_request(return_request)
		_plugin_singleton.fetch([pack_name], signal_id)
		_asset_pack_to_request_map[pack_name] = return_request
	_play_asset_pack_manager_mutex.unlock()

	return return_request

# -----------------------------------------------------------------------------
# Cancels an asset pack request specified by pack_name, true if success. 
# 
# Note: Only active downloads can be canceled.
# -----------------------------------------------------------------------------
func cancel_asset_pack_request(pack_name : String) -> bool:
	var raw_dict = _plugin_singleton.cancel([pack_name])
	var updated_asset_pack_states : PlayAssetPackStates = PlayAssetPackStates.new(raw_dict)
	
	# return false if no matching pack_name found in updated PlayAssetPackStates
	if not updated_asset_pack_states.get_pack_states().has(pack_name):
		return false
	
	var updated_asset_pack_state : PlayAssetPackState = updated_asset_pack_states.get_pack_states()[pack_name]
	var updated_asset_pack_status = updated_asset_pack_state.get_status()
	
	var cancellation_success = AssetPackStatus.CANCELED == AssetPackStatus.CANCELED
	if cancellation_success:
		_asset_pack_to_request_map.erase(pack_name)
	
	return cancellation_success

# -----------------------------------------------------------------------------
# Deletes the specified asset pack from the internal storage of the app.
#
# Use this method to delete asset packs instead of deleting files manually. 
# This ensures that the asset pack will not be re-downloaded during an app 
# update.
#
# If the asset pack is currently being downloaded or installed, this method 
# does not cancel the process. For this case, use cancel_asset_pack_request()
# instead.
#
# Returns a PlayAssetPackRemoveRequest object that can emit onComplete signal
# once the remove request succeeded or failed.
# -----------------------------------------------------------------------------
func remove_pack(pack_name: String):
	var return_request = PlayAssetPackRemoveRequest.new()
	var signal_id = _request_tracker.register_request(return_request)
	_plugin_singleton.removePack(pack_name, signal_id)
	return return_request

# -----------------------------------------------------------------------------
# Shows a confirmation dialog to resume all pack downloads that are currently 
# in the WAITING_FOR_WIFI state. If the user accepts the dialog, packs are 
# downloaded over cellular data. 
# 
# The status of an asset pack is set to WAITING_FOR_WIFI if the user is 
# currently not on a Wi-Fi connection and the asset pack is large or the user 
# has set their download preference in the Play Store to only download apps 
# over Wi-Fi. By showing this dialog, your app can ask the user if they accept 
# downloading the asset pack over cellular data instead of waiting for Wi-Fi.
#
# Returns a PlayCellularDataConfirmationRequest object that can emit onComplete 
# signal once the the dialog has been accepted, denied, closed.
# -----------------------------------------------------------------------------
func show_cellular_data_confirmation():
	var return_request = PlayCellularDataConfirmationRequest.new()
	var signal_id = _request_tracker.register_request(return_request)
	_plugin_singleton.showCellularDataConfirmation(signal_id)
	return return_request

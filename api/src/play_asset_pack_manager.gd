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
# ##############################################################################
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

# Dictionary that stores the mapping of pack_name to relevant Request objects	
var _asset_pack_to_request_map : Dictionary	
var _play_asset_pack_manager_mutex : Mutex	
var _asset_pack_state_cache : Dictionary

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
# Connect signals, allowing signals emitted from the plugin to be correctly
# linked to functions in the front-facing API.
# -----------------------------------------------------------------------------
func _connect_plugin_signals():
	if _plugin_singleton != null:
		_plugin_singleton.connect("assetPackStateUpdated", self, "_route_asset_pack_state_updated")
		_plugin_singleton.connect("fetchSuccess", self, "_forward_fetch_success")
		_plugin_singleton.connect("fetchError", self, "_forward_fetch_error")
		_plugin_singleton.connect("getPackStatesSuccess", self, "_forward_get_pack_states_success")
		_plugin_singleton.connect("getPackStatesError", self, "_forward_get_pack_states_error")
		_plugin_singleton.connect("removePackSuccess", self, "_forward_remove_pack_success")
		_plugin_singleton.connect("removePackError", self, "_forward_remove_pack_error")
		_plugin_singleton.connect("showCellularDataConfirmationSuccess", self, \
			"_forward_show_cellular_data_confirmation_success")
		_plugin_singleton.connect("showCellularDataConfirmationError", self, \
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
# Helper function used to release reference of request objects from pack_name
# to request map.
# -----------------------------------------------------------------------------
func _remove_request_reference_from_map(pack_name : String):
	_play_asset_pack_manager_mutex.lock()	
	_asset_pack_to_request_map.erase(pack_name)
	_play_asset_pack_manager_mutex.unlock()	

# -----------------------------------------------------------------------------
# Helper function that synchronizes relevant request object's state upon 
# receiving assetPackStateUpdated signal.
# -----------------------------------------------------------------------------
func _route_asset_pack_state_updated(result : Dictionary):
	var updated_state : PlayAssetPackState = PlayAssetPackState.new(result)
	var pack_name = updated_state.get_name()
	var updated_status = updated_state.get_status()
	
	_play_asset_pack_manager_mutex.lock()	
	# update all related request object's states	
	if _asset_pack_to_request_map.has(pack_name):	
		var request_list = _asset_pack_to_request_map[pack_name]	
		for request in request_list:	
			# Since assetPackStateUpdated and fetchSuccess/Error might contain duplicate updates,
			# we will only route non-duplicate updates to request object after we already received 
			# fetchSuccess/Error signal.
			var received_fetch_callback = request.get_state().get_status() != PlayAssetPackManager.AssetPackStatus.UNKNOWN and\
				request.get_state().get_total_bytes_to_download() != 0
			var duplicate_state = request.get_state().to_dict().hash() == result.hash()
			if received_fetch_callback and not duplicate_state:
				# Since devs might read request's state while we are updating it, we need to call this	
				# function from main thread.
				request.call_deferred("_on_state_updated", result)	

		# if reached terminal state, release references	
		if updated_status in _PACK_TERMINAL_STATES:	
			_asset_pack_to_request_map.erase(pack_name)
	
	# only emit non-repeated state_updated signals
	if _asset_pack_state_cache.has(pack_name) and _asset_pack_state_cache[pack_name].hash() != result.hash():
		_asset_pack_state_cache[pack_name] = result
		# emit state updated signal on main thread
		call_deferred("emit_signal", "state_updated", pack_name, updated_state)
	
	_play_asset_pack_manager_mutex.unlock()

# -----------------------------------------------------------------------------
# Helper functions called by used to emit state_updated signal with, able to 
# filter out duplicate state_updated signals.
# -----------------------------------------------------------------------------
func _forward_high_level_state_updated_signal(pack_name : String, state : Dictionary):
	# update cache, since this function can be called by multiple request objects with same packName
	_play_asset_pack_manager_mutex.lock()
	if not _asset_pack_state_cache.has(pack_name) or _asset_pack_state_cache[pack_name].hash() != state.hash():
		_asset_pack_state_cache[pack_name] = state
		# emit state updated signal on main thread
		var state_object : PlayAssetPackState = PlayAssetPackState.new(state)
		call_deferred("emit_signal", "state_updated", pack_name, state_object)
	_play_asset_pack_manager_mutex.unlock()

# -----------------------------------------------------------------------------
# Helper functions that forward signals emitted from the plugin
# -----------------------------------------------------------------------------
func _forward_fetch_success(result : Dictionary, signal_id : int):
	var target_request : PlayAssetPackFetchRequest = _request_tracker.lookup_request(signal_id)
	target_request.call_deferred("_on_fetch_success", result)
	_request_tracker.unregister_request(signal_id)

func _forward_fetch_error(error : Dictionary, signal_id : int):
	var target_request : PlayAssetPackFetchRequest = _request_tracker.lookup_request(signal_id)
	target_request.call_deferred("_on_fetch_error", error)
	_request_tracker.unregister_request(signal_id)

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
	var return_request = PlayAssetPackFetchRequest.new(pack_name)
	var signal_id = _request_tracker.register_request(return_request)
	
	# Update mapping of pack_name to request object, so that assetStateUpdated global signal	
	# can be correctly routed to this request object.	
	_play_asset_pack_manager_mutex.lock()	
	if _asset_pack_to_request_map.has(pack_name):	
		_asset_pack_to_request_map[pack_name].append(return_request)	
	else:	
		_asset_pack_to_request_map[pack_name] = [return_request]	
	_play_asset_pack_manager_mutex.unlock()
	
	_plugin_singleton.fetch([pack_name], signal_id)
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
	
	return updated_asset_pack_status == AssetPackStatus.CANCELED

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

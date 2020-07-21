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
# modifying the configurations in Project -> Project Settings -> AutoLoad
#
# ##############################################################################
extends Node

var _plugin_singleton : Object
var _request_tracker : PlayAssetDeliveryRequestTracker

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

# -----------------------------------------------------------------------------
# Setup
# -----------------------------------------------------------------------------
func _ready():
	_initialize()

func _initialize():
	_plugin_singleton = _initialize_plugin()
	_connect_plugin_signals()
	_request_tracker = PlayAssetDeliveryRequestTracker.new()

# -----------------------------------------------------------------------------
# Connect signals, allowing signals emitted from the plugin to be correctly
# linked to functions in the front-facing API
# -----------------------------------------------------------------------------
func _connect_plugin_signals():
	if _plugin_singleton != null:
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
# Helper functions that forward signals emitted from the plugin
# -----------------------------------------------------------------------------
func _forward_show_cellular_data_confirmation_success(result : int, signal_id : int):
	var target_request = _request_tracker.lookup_request(signal_id)
	target_request.on_show_cellular_data_confirmation_success(result)
	_request_tracker.unregister_request(signal_id)

func _forward_show_cellular_data_confirmation_error(error : Dictionary, signal_id : int):
	var target_request = _request_tracker.lookup_request(signal_id)
	target_request.on_show_cellular_data_confirmation_error(error)
	_request_tracker.unregister_request(signal_id)

func _forward_remove_pack_success(signal_id : int):
	var target_request = _request_tracker.lookup_request(signal_id)
	target_request.on_remove_pack_success()
	_request_tracker.unregister_request(signal_id)

func _forward_remove_pack_error(error : Dictionary, signal_id : int):
	var target_request = _request_tracker.lookup_request(signal_id)
	target_request.on_remove_pack_error(error)
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
# Cancels an asset pack request specified by pack_name, true if success. 
# Note: Only active downloads can be canceled.
# -----------------------------------------------------------------------------
func cancel_asset_pack_request(pack_name : String) -> bool:
	var raw_dict = _plugin_singleton.cancel([pack_name])
	var updated_asset_pack_states : PlayAssetPackStates = PlayAssetPackStates.new(raw_dict)
	
	# return false if no matching pack_name found in updated PlayAssetPackStates
	if not pack_name in updated_asset_pack_states.get_pack_states().keys():
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

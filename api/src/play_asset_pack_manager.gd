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
# Returns the location of all installed asset packs. More specifically, a 
# Dictionary, where for each entry, the key is the asset pack anme and value is 
# the corresponding PlayAssetLocation object.
# -----------------------------------------------------------------------------
func get_pack_locations() -> Dictionary:
	var return_dict = Dictionary()
	var raw_dict = _plugin_singleton.getPackLocations()
	
	# convert inner dictionaries in raw_dict to PlayAssetLocation objects
	for key in raw_dict.keys():
		return_dict[key] = PlayAssetPackLocation.new(raw_dict[key])
	
	return return_dict

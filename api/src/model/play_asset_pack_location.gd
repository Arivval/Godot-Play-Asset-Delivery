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
# Wraps Play Core's AssetPackLocation which represents the location of an an 
# asset pack on disk.
#
# ##############################################################################
class_name PlayAssetPackLocation
extends Object

var _asset_pack_location_dict : Dictionary

func _init(init_dictionary : Dictionary):
	_asset_pack_location_dict = init_dictionary.duplicate()

# -----------------------------------------------------------------------------
# Returns the file path to the folder containing the pack's assets, if the 
# storage method is STORAGE_FILES.
# -----------------------------------------------------------------------------
func get_assets_path() -> String:
	return _asset_pack_location_dict["assetsPath"]

# -----------------------------------------------------------------------------
# Returns AssetPackStorageMethod enum, which represents whether the pack is 
# installed as an APK or extracted into a folder on the filesystem.
# -----------------------------------------------------------------------------
func get_storage_method() -> int:
	return _asset_pack_location_dict["packStorageMethod"]

# -----------------------------------------------------------------------------
# Returns the file path to the folder containing the extracted asset pack, if 
# the storage method is STORAGE_FILES.
# -----------------------------------------------------------------------------
func get_path() -> String:
	return _asset_pack_location_dict["path"]

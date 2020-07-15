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
# Wraps Play Core's AssetLocation which represents the location of an Asset 
# within an asset pack on disk.
#
# ##############################################################################
class_name PlayAssetLocation
extends Object

var _asset_location_dict : Dictionary

func _init(init_dictionary : Dictionary):
	_asset_location_dict = init_dictionary.duplicate()

# -----------------------------------------------------------------------------
# Returns the file offset where the asset starts, in bytes. If the 
# AssetPackStorageMethod for the pack is STORAGE_FILES, the offset will be 0.
# -----------------------------------------------------------------------------
func get_offset() -> int:
	return _asset_location_dict["offset"]

# -----------------------------------------------------------------------------
# If the AssetPackStorageMethod for the pack is STORAGE_FILES, return the path 
# to the specific asset. Otherwise return the path to the APK containing the
# asset.
# -----------------------------------------------------------------------------
func get_path() -> String:
	return _asset_location_dict["path"]

# -----------------------------------------------------------------------------
# Returns the size of the asset, in bytes.
# -----------------------------------------------------------------------------
func get_size() -> int:
	return _asset_location_dict["size"]

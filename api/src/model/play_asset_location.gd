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
# This class provides a constructor to create new PlayAssetLocation objects 
# based on input Dictionary. Provides relevant get methods.
#
# ##############################################################################
class_name PlayAssetLocation
extends Object

var _asset_location_dict : Dictionary

func _init(init_dictionary : Dictionary):
	_asset_location_dict = init_dictionary.duplicate()

func get_offset() -> int:
	return _asset_location_dict["offset"]

func get_path() -> String:
	return _asset_location_dict["path"]

func get_size() -> int:
	return _asset_location_dict["size"]

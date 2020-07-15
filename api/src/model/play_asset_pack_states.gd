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
# Wraps Play Core's AssetPackStates which represents the states for a 
# collections of pack.
#
# ##############################################################################
class_name PlayAssetPackStates
extends Object

var _asset_pack_states_dict : Dictionary

func _init(init_dictionary : Dictionary):
	_asset_pack_states_dict = Dictionary()
	_asset_pack_states_dict["totalBytes"] = init_dictionary["totalBytes"]
	
	var init_pack_states_dict : Dictionary = init_dictionary["packStates"]
	var pack_states_object_dict : Dictionary = Dictionary()
	for key in init_pack_states_dict.keys():
		pack_states_object_dict[key] = PlayAssetPackState.new(init_pack_states_dict[key])
	_asset_pack_states_dict["packStates"] = pack_states_object_dict

# -----------------------------------------------------------------------------
# Returns total size of all requested packs in bytes.
# -----------------------------------------------------------------------------
func get_total_bytes() -> int:
	return _asset_pack_states_dict["totalBytes"]

# -----------------------------------------------------------------------------
# Returns a map from a pack's name to its state.
# -----------------------------------------------------------------------------
func get_pack_states() -> Dictionary:
	return _asset_pack_states_dict["packStates"].duplicate()

# -----------------------------------------------------------------------------
# Returns a PlayAssetPackState object with matching pack name, null if not 
# found.
# -----------------------------------------------------------------------------
func get_pack_state(_pack_name : String) -> PlayAssetPackState:
	return _asset_pack_states_dict["packStates"][_pack_name]

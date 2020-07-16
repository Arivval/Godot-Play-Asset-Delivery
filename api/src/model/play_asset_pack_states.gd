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

# -----------------------------------------------------------------------------
# Constant declaration for Dictionary key Strings
# -----------------------------------------------------------------------------
const _TOTAL_BYTES_KEY : String = "totalBytes"
const _PACK_STATES_KEY : String = "packStates"

var _total_bytes : int
var _pack_states : Dictionary

func _init(init_dictionary : Dictionary):
	_total_bytes = init_dictionary[_TOTAL_BYTES_KEY]
	
	var init_pack_states_dict : Dictionary = init_dictionary[_PACK_STATES_KEY]
	var pack_states_object_dict : Dictionary = Dictionary()
	for key in init_pack_states_dict.keys():
		pack_states_object_dict[key] = PlayAssetPackState.new(init_pack_states_dict[key])
	_pack_states = pack_states_object_dict

# -----------------------------------------------------------------------------
# Returns total size of all requested packs in bytes.
# -----------------------------------------------------------------------------
func get_total_bytes() -> int:
	return _total_bytes

# -----------------------------------------------------------------------------
# Returns a Dictionary where for each entry, the key is the pack_name and value is the 
# corresponding PlayAssetPackState object.
# -----------------------------------------------------------------------------
func get_pack_states() -> Dictionary:
	return _pack_states.duplicate()

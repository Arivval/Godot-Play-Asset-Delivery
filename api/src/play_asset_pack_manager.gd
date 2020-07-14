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
extends Node

var _plugin_singleton : Object

var play_asset_location : Resource

func _ready():
	_initialize()

func _initialize():
	_plugin_singleton = _initialize_plugin()
	
func _initialize_plugin() -> Object:
	if Engine.has_singleton("PlayAssetDelivery"):
		return Engine.get_singleton("PlayAssetDelivery")
	else:
		push_error("Android plugin singleton not found!")
		return null

func get_pack_location(pack_name : String):
	var query_dict = _plugin_singleton.getPackLocation(pack_name)
	if query_dict == null:
		return null
	return PlayAssetLocation.new(query_dict)

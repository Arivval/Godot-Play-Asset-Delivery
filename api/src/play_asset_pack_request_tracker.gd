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
# The PlayAssetPackRequestTracker class generates unique signal_id integers and
# keeps a mapping of signal_id to Request objects. This signal_id is used as an
# identifier and passed to the Android plugin. Eventually the Android plugin will
# emit signals along with this signal_id. In this way we can know which signal 
# emitted from the plugin corresponds to which Request object
#
# ##############################################################################
class_name PlayAssetPackRequestTracker
extends Object

var _signal_id_counter : int
var _signal_id_to_request_map : Dictionary

func _init():
	_signal_id_counter = 0
	_signal_id_to_request_map = Dictionary()

func get_current_signal_id() -> int:
	return _signal_id_counter

func increment_signal_id() -> void:
	_signal_id_counter += 1

func register_request(request : PlayAssetPackRequest) -> int:
	var return_signal_id = _signal_id_counter
	_signal_id_to_request_map[return_signal_id] = request
	increment_signal_id()
	return return_signal_id

func lookup_request(signal_id : int) -> PlayAssetPackRequest:
	if signal_id in _signal_id_to_request_map:
		return _signal_id_to_request_map[signal_id]
	return null

func remove_request(signal_id : int) -> void:
	if signal_id in _signal_id_to_request_map:
		_signal_id_to_request_map.erase(signal_id)


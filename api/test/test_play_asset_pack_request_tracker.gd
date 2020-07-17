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

extends "res://test/test_helper/base_test_class.gd"

func test_register_request_single_request():
	var test_request_tracker = PlayAssetPackRequestTracker.new()
	var test_request_object = PlayAssetPackRequest.new()
	
	# register the request
	var test_signal_id = test_request_tracker.register_request(test_request_object)
	
	# lookup the request with signal_id
	assert_eq(test_signal_id, PlayAssetPackRequestTracker._SIGNAL_ID_MIN)
	assert_eq(test_request_tracker.lookup_request(test_signal_id), test_request_object)
	
func test_register_request_multiple_requests():
	var test_request_tracker = PlayAssetPackRequestTracker.new()

	var test_request_object1 = PlayAssetPackRequest.new()
	var test_request_object2 = PlayAssetPackRequest.new()
	var test_request_object3 = PlayAssetPackRequest.new()
	var test_request_object4 = PlayAssetPackRequest.new()
	var test_request_object5 = PlayAssetPackRequest.new()

	# register multiple requests
	var test_signal_id1 = test_request_tracker.register_request(test_request_object1)
	var test_signal_id2 = test_request_tracker.register_request(test_request_object2)
	var test_signal_id3 = test_request_tracker.register_request(test_request_object3)
	var test_signal_id4 = test_request_tracker.register_request(test_request_object4)
	var test_signal_id5 = test_request_tracker.register_request(test_request_object5)
	
	assert_eq(test_signal_id1, PlayAssetPackRequestTracker._SIGNAL_ID_MIN)
	assert_eq(test_signal_id2, PlayAssetPackRequestTracker._SIGNAL_ID_MIN + 1)
	assert_eq(test_signal_id3, PlayAssetPackRequestTracker._SIGNAL_ID_MIN + 2)
	assert_eq(test_signal_id4, PlayAssetPackRequestTracker._SIGNAL_ID_MIN + 3)
	assert_eq(test_signal_id5, PlayAssetPackRequestTracker._SIGNAL_ID_MIN + 4)

	# lookup requests
	assert_eq(test_request_tracker.lookup_request(test_signal_id1), test_request_object1)
	assert_eq(test_request_tracker.lookup_request(test_signal_id2), test_request_object2)
	assert_eq(test_request_tracker.lookup_request(test_signal_id3), test_request_object3)
	assert_eq(test_request_tracker.lookup_request(test_signal_id4), test_request_object4)
	assert_eq(test_request_tracker.lookup_request(test_signal_id5), test_request_object5)

func test_lookup_request_nonexistent_signal_id():
	var test_request_tracker = PlayAssetPackRequestTracker.new()
	var test_signal_id = 42
	assert_eq(test_request_tracker.lookup_request(test_signal_id), null)

func test_remove_request_valid():
	var test_request_tracker = PlayAssetPackRequestTracker.new()
	var test_request_object = PlayAssetPackRequest.new()
	
	var test_signal_id = test_request_tracker.register_request(test_request_object)
	test_request_tracker.unregister_request(test_signal_id)
	
	assert_true(not test_signal_id in test_request_tracker._signal_id_to_request_map)
	assert_eq(test_request_tracker.lookup_request(test_signal_id), null)

func test_signal_id_handle_overflow():
	var test_request_tracker = PlayAssetPackRequestTracker.new()
	var test_request_object = PlayAssetPackRequest.new()
	
	# manual set _signal_id_counter to _SIGNAL_ID_MAX
	test_request_tracker._signal_id_counter = PlayAssetPackRequestTracker._SIGNAL_ID_MAX

	var test_signal_id = test_request_tracker.register_request(test_request_object)
	
	# updated _signal_id_counter should be _SIGNAL_ID_MIN
	assert_eq(test_request_tracker.get_current_signal_id(), PlayAssetPackRequestTracker._SIGNAL_ID_MIN)
	assert_eq(test_request_tracker.lookup_request(test_signal_id), test_request_object)

func test_signal_id_skip_existing_ids():
	var test_request_tracker = PlayAssetPackRequestTracker.new()
	var test_request_object = PlayAssetPackRequest.new()
	
	var existing_request_object1 = PlayAssetPackRequest.new()
	var existing_request_object2 = PlayAssetPackRequest.new()
	
	test_request_tracker._signal_id_to_request_map[0] = existing_request_object1
	test_request_tracker._signal_id_to_request_map[1] = existing_request_object2
	
	# the current _signal_id_counter is still _SIGNAL_ID_MIN - 1, but the next available id in mp 
	# will be 2
	assert_eq(test_request_tracker._signal_id_counter, PlayAssetPackRequestTracker._SIGNAL_ID_MIN - 1)
	
	var test_signal_id = test_request_tracker.register_request(test_request_object)
	
	assert_eq(test_signal_id, PlayAssetPackRequestTracker._SIGNAL_ID_MIN + 2)
	assert_eq(test_request_tracker.lookup_request(test_signal_id), test_request_object)
	# check if existing request objects are not overwritten
	assert_eq(test_request_tracker.lookup_request(PlayAssetPackRequestTracker._SIGNAL_ID_MIN), existing_request_object1)
	assert_eq(test_request_tracker.lookup_request(PlayAssetPackRequestTracker._SIGNAL_ID_MIN + 1), existing_request_object2)


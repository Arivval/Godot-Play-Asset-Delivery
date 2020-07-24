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

func create_play_asset_pack_manager(mock_plugin):
	var test_object = partial_double("res://src/play_asset_pack_manager.gd").new()
	stub(test_object, "_initialize_plugin").to_return(mock_plugin)
	test_object._initialize()
	test_object._connect_plugin_signals()
	return test_object

func test_get_asset_location_valid():
	var test_pack = "testPack"
	var test_path = "/path/"
	var return_dict = {
		PlayAssetLocation._OFFSET_KEY: 42, 
		PlayAssetLocation._PATH_KEY: "path/", 
		PlayAssetLocation._SIZE_KEY: 100
	}
	
	var mock_plugin = FakeAndroidPlugin.new()
	mock_plugin.add_asset_location(test_pack, test_path, return_dict)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : PlayAssetLocation = test_object.get_asset_location(test_pack, test_path)
	
	assert_asset_location_eq_dict(test_result, return_dict)

func test_get_asset_location_not_exist():
	var test_pack = "testPack"
	var test_path = "/path/"
	var pack_dict = {
		PlayAssetLocation._OFFSET_KEY: 42, 
		PlayAssetLocation._PATH_KEY: "path/", 
		PlayAssetLocation._SIZE_KEY: 100
	}
	
	var mock_plugin = FakeAndroidPlugin.new()
	mock_plugin.add_asset_location(test_pack, test_path, pack_dict)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : PlayAssetLocation = test_object.get_asset_location(test_pack, "/otherPath/")
	
	assert_eq(test_result, null)

func test_get_asset_pack_location_valid():
	var test_pack = "testPack"
	var return_dict = {
		PlayAssetPackLocation._ASSETS_PATH_KEY: "/assetsPath/", 
		PlayAssetPackLocation._PACK_STORAGE_METHOD_KEY: PlayAssetPackManager.AssetPackStorageMethod.STORAGE_FILES, 
		PlayAssetLocation._PATH_KEY: "/path/"
	}
	
	var mock_plugin = FakeAndroidPlugin.new()
	mock_plugin.add_asset_pack_location(test_pack, return_dict)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : PlayAssetPackLocation = test_object.get_pack_location(test_pack)
	
	assert_asset_pack_location_eq_dict(test_result, return_dict)

func test_get_asset_pack_location_not_exist():
	var test_pack = "testPack"
	var return_dict = {
		PlayAssetPackLocation._ASSETS_PATH_KEY: "/assetsPath/", 
		PlayAssetPackLocation._PACK_STORAGE_METHOD_KEY: PlayAssetPackManager.AssetPackStorageMethod.STORAGE_FILES, 
		PlayAssetLocation._PATH_KEY: "/path/"
	}
	
	var mock_plugin = FakeAndroidPlugin.new()
	mock_plugin.add_asset_pack_location(test_pack, return_dict)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : PlayAssetPackLocation = test_object.get_pack_location("notExistPack")
	
	assert_eq(test_result, null)

func test_get_asset_pack_location_non_empty():
	var test_dict = create_mock_asset_locations_dict()
	
	var mock_plugin = FakeAndroidPlugin.new()
	mock_plugin.set_asset_pack_locations(test_dict)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : Dictionary = test_object.get_pack_locations()
	
	assert_asset_pack_locations_eq_dict(test_result, test_dict)

func test_get_asset_pack_location_empty():
	var test_dict = Dictionary()
	
	var mock_plugin = FakeAndroidPlugin.new()
	mock_plugin.set_asset_pack_locations(test_dict)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : Dictionary = test_object.get_pack_locations()
	
	assert_eq(test_result.size(), 0)

func test_cancel_asset_pack_request_success():
	var test_pack_name = "assetPackName"
	var test_state_dict = create_mock_asset_pack_state_with_status_dict(
		test_pack_name, PlayAssetPackManager.AssetPackStatus.DOWNLOADING)

	var test_states_dict = {
		PlayAssetPackStates._TOTAL_BYTES_KEY: test_state_dict[PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY],
		PlayAssetPackStates._PACK_STATES_KEY: {
			test_pack_name: test_state_dict
		}
	}
	
	var mock_plugin = FakeAndroidPlugin.new()
	mock_plugin.set_asset_pack_states_store(test_states_dict)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : bool = test_object.cancel_asset_pack_request(test_pack_name)
	
	assert_eq(test_result, true)

func test_cancel_asset_pack_request_failed():
	var test_pack_name = "assetPackName"
	# only ongoing downloads can be canceled, so we are unable to cancel a pack with UNKNOWN status
	var test_state_dict = create_mock_asset_pack_state_with_status_dict(
		test_pack_name, PlayAssetPackManager.AssetPackStatus.UNKNOWN)

	var test_states_dict = {
		PlayAssetPackStates._TOTAL_BYTES_KEY: test_state_dict[PlayAssetPackState._TOTAL_BYTES_TO_DOWNLOAD_KEY],
		PlayAssetPackStates._PACK_STATES_KEY: {
			test_pack_name: test_state_dict
		}
	}
	
	var mock_plugin = FakeAndroidPlugin.new()
	mock_plugin.set_asset_pack_states_store(test_states_dict)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : bool = test_object.cancel_asset_pack_request(test_pack_name)
	
	assert_eq(test_result, false)

func test_cancel_asset_pack_request_non_existing_pack_name():
	var test_pack_name = "assetPackName"

	var mock_plugin = FakeAndroidPlugin.new()
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_result : bool = test_object.cancel_asset_pack_request(test_pack_name)
	assert_eq(test_result, false)

func test_fetch_asset_pack_success():
	var mock_plugin = FakeAndroidPlugin.new()

	# configure what should be emitted upon fetch_asset_pack() call
	var test_pack_name = "testPack"
	
	var test_asset_pack_state = create_mock_asset_pack_state_with_status_and_progress_dict(test_pack_name, \
		PlayAssetPackManager.AssetPackStatus.PENDING, 0, 4096)
	
	# the plugin call will return an AssetPackStates dictionary enclosing the given test_asset_pack_state
	var test_asset_pack_states = create_mock_asset_pack_states_with_single_state_dict(test_asset_pack_state)
	var signal_info = FakePackStatesInfo.new(true, \
		test_asset_pack_states, {})
	mock_plugin.set_fake_fetch_info(signal_info)
	
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var request_object = test_object.fetch_asset_pack(test_pack_name)
	# weakref used to test for memory leak
	var request_object_reference = weakref(request_object)
	
	# connect to helper function, simulating the workflow of connecting callback to signal
	request_object.connect("request_completed", self, "assert_fetch_signal_is_success")
	
	# yield to the request_completed signal for no longer than 1 seconds and assert for signal emitted
	yield(yield_to(request_object, "request_completed", 1), YIELD)
	assert_signal_emitted(request_object, "request_completed", "signal should have emitted")
	
	# assert using getters, simulating the workflow of yielding the signals
	assert_true(request_object.get_did_succeed())
	assert_eq(request_object.get_pack_name(), test_pack_name)
	assert_eq(request_object.get_error(), null)
	assert_asset_pack_state_eq_dict(request_object.get_state(), test_asset_pack_state)
	
	# Watch our request object and assert for multiple state_updated signals
	var signal_argument_count = 2
	var signal_captor = SignalCaptor.new(signal_argument_count)
	request_object.connect("state_updated", signal_captor, "signal_call_back")
	
	# Emit a stream of state_updated signal
	var updated_state1 = create_mock_asset_pack_state_with_status_and_progress_dict(test_pack_name, \
		PlayAssetPackManager.AssetPackStatus.DOWNLOADING, 256, 4096)
	var updated_signal_info1 = FakePackStateInfo.new(updated_state1)
	mock_plugin.trigger_asset_pack_state_updated_signal(updated_signal_info1)
	yield(yield_to(request_object, "state_updated", 1), YIELD)
	updated_signal_info1.thread.wait_to_finish()
	
	var updated_state2 = create_mock_asset_pack_state_with_status_and_progress_dict(test_pack_name, \
		PlayAssetPackManager.AssetPackStatus.WAITING_FOR_WIFI, 256, 4096)
	var updated_signal_info2 = FakePackStateInfo.new(updated_state2)
	mock_plugin.trigger_asset_pack_state_updated_signal(updated_signal_info2)
	yield(yield_to(request_object, "state_updated", 1), YIELD)
	updated_signal_info2.thread.wait_to_finish()
	
	var updated_state3 = create_mock_asset_pack_state_with_status_and_progress_dict(test_pack_name, \
		PlayAssetPackManager.AssetPackStatus.DOWNLOADING, 2048, 4096)
	var updated_signal_info3 = FakePackStateInfo.new(updated_state3)
	mock_plugin.trigger_asset_pack_state_updated_signal(updated_signal_info3)
	yield(yield_to(request_object, "state_updated", 1), YIELD)
	updated_signal_info3.thread.wait_to_finish()
	
	var updated_state4 = create_mock_asset_pack_state_with_status_and_progress_dict(test_pack_name, \
		PlayAssetPackManager.AssetPackStatus.COMPLETED, 4096, 4096)
	var updated_signal_info4 = FakePackStateInfo.new(updated_state4)
	mock_plugin.trigger_asset_pack_state_updated_signal(updated_signal_info4)
	yield(yield_to(request_object, "state_updated", 1), YIELD)
	updated_signal_info4.thread.wait_to_finish()
	
	# assert signal_captor is as expected
	var result_params_store = signal_captor.received_params_store
	var expected_state_list = [updated_state1, updated_state2, updated_state3, updated_state4]
	assert_eq(result_params_store.size(), 4)
	# assert all entries in result_params_store
	for i in range(4):
		assert_eq(result_params_store[i].size(), 2)
		assert_eq(result_params_store[i][0], test_pack_name)
		assert_asset_pack_state_eq_dict(result_params_store[i][1], expected_state_list[i])
	
	# releases reference
	request_object.free()
	# assert reference is freed
	assert_true(not request_object_reference.get_ref())

func assert_fetch_signal_is_success(did_succeed : bool, pack_name : String, \
	result : PlayAssetPackState, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	var expected_pack_name = "testPack"
	var expected_pack_state_dict = create_mock_asset_pack_state_with_status_and_progress_dict(expected_pack_name, \
		PlayAssetPackManager.AssetPackStatus.PENDING, 0, 4096)
	assert_true(did_succeed)
	assert_eq(pack_name, expected_pack_name)
	assert_asset_pack_state_eq_dict(result, expected_pack_state_dict)
	assert_eq(exception, null)

func test_fetch_asset_pack_error():
	var mock_plugin = FakeAndroidPlugin.new()
	
	var signal_info = FakePackStatesInfo.new(false, {}, \
		create_mock_asset_pack_java_lang_exception_dict())
	mock_plugin.set_fake_fetch_info(signal_info)
	
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_pack_name = "random pack name"
	var request_object = test_object.fetch_asset_pack(test_pack_name)
	# weakref used to test for memory leak
	var request_object_reference = weakref(request_object)
	
	# connect to helper function, simulating the workflow of connecting callback to signal
	request_object.connect("request_completed", self, "assert_fetch_signal_is_error")
	
	# yield to the request_completed signal for no longer than 1 seconds and assert for signal emitted
	yield(yield_to(request_object, "request_completed", 1), YIELD)
	assert_signal_emitted(request_object, "request_completed", "signal should have emitted")
	
	# assert using getters, simulating the workflow of yielding the signals
	assert_true(not request_object.get_did_succeed())
	assert_eq(request_object.get_pack_name(), test_pack_name)
	assert_asset_pack_exception_eq_dict(request_object.get_error(), create_mock_asset_pack_java_lang_exception_dict())
	assert_eq(request_object.get_state(), null)
	
	# join instantiated thread
	signal_info.thread.wait_to_finish()
	
	# releases reference
	request_object.free()
	# assert reference is freed
	assert_true(not request_object_reference.get_ref())

func assert_fetch_signal_is_error(did_succeed : bool, pack_name : String, \
	result : PlayAssetPackState, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	assert_true(not did_succeed)
	assert_eq(pack_name, "random pack name")
	assert_asset_pack_exception_eq_dict(exception, create_mock_asset_pack_java_lang_exception_dict())
	assert_eq(result, null)

func test_fetch_asset_pack_non_existent_pack():
	var mock_plugin = FakeAndroidPlugin.new()

	# configure what should be emitted upon get_asset_pack_state() call
	var test_asset_pack_state = create_mock_asset_pack_state_dict()
	var test_pack_name = test_asset_pack_state[PlayAssetPackState._NAME_KEY]
	
	# the plugin call will return an AssetPackStates dictionary enclosing the given test_asset_pack_state
	var test_asset_pack_states = create_mock_asset_pack_states_with_single_state_dict(test_asset_pack_state)
	var signal_info = FakePackStatesInfo.new(true, \
		test_asset_pack_states, {})
	mock_plugin.set_fake_fetch_info(signal_info)
	
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	# AssetPackStates dictionary returned by plugin should not contain this pack_name
	var non_existent_pack_name = "non_existent_pack"
	var request_object = test_object.fetch_asset_pack(non_existent_pack_name)
	# weakref used to test for memory leak
	var request_object_reference = weakref(request_object)
	
	# connect to helper function, simulating the workflow of connecting callback to signal
	request_object.connect("request_completed", self, "assert_fetch_signal_non_existent_pack")
	
	# yield to the request_completed signal for no longer than 1 seconds and assert for signal emitted
	yield(yield_to(request_object, "request_completed", 1), YIELD)
	assert_signal_emitted(request_object, "request_completed", "signal should have emitted")
	
	# assert using getters, simulating the workflow of yielding the signals
	assert_true(not request_object.get_did_succeed())
	assert_eq(request_object.get_pack_name(), non_existent_pack_name)
	assert_eq(request_object.get_error(), null)
	assert_eq(request_object.get_state(), null)
	
	# join instantiated thread
	signal_info.thread.wait_to_finish()
	
	# releases reference
	request_object.free()
	# assert reference is freed
	assert_true(not request_object_reference.get_ref())

func assert_fetch_signal_non_existent_pack(did_succeed : bool, pack_name : String, \
	result : PlayAssetPackState, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	assert_true(not did_succeed)
	assert_eq(pack_name, "non_existent_pack")
	assert_eq(result, null)
	assert_eq(exception, null)

func test_get_asset_pack_state_success():
	var mock_plugin = FakeAndroidPlugin.new()

	# configure what should be emitted upon get_asset_pack_state() call
	var test_asset_pack_state = create_mock_asset_pack_state_dict()
	var test_pack_name = test_asset_pack_state[PlayAssetPackState._NAME_KEY]
	
	# the plugin call will return an AssetPackStates dictionary enclosing the given test_asset_pack_state
	var test_asset_pack_states = create_mock_asset_pack_states_with_single_state_dict(test_asset_pack_state)
	var signal_info = FakePackStatesInfo.new(true, \
		test_asset_pack_states, {})
	mock_plugin.set_fake_get_pack_states_info(signal_info)
	
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var request_object = test_object.get_asset_pack_state(test_pack_name)
	
	# connect to helper function, simulating the workflow of connecting callback to signal
	request_object.connect("request_completed", self, "assert_get_asset_pack_state_signal_is_success")
	
	# yield to the request_completed signal for no longer than 1 seconds and assert for signal emitted
	yield(yield_to(request_object, "request_completed", 1), YIELD)
	assert_signal_emitted(request_object, "request_completed", "signal should have emitted")
	
	# assert using getters, simulating the workflow of yielding the signals
	assert_true(request_object.get_did_succeed())
	assert_eq(request_object.get_pack_name(), test_pack_name)
	assert_eq(request_object.get_error(), null)
	assert_asset_pack_state_eq_dict(request_object.get_result(), test_asset_pack_state)
	
	# join instantiated thread
	signal_info.thread.wait_to_finish()

func assert_get_asset_pack_state_signal_is_success(did_succeed : bool, pack_name : String, \
	result : PlayAssetPackState, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	var expected_pack_state_dict = create_mock_asset_pack_state_dict()
	var expected_pack_name = expected_pack_state_dict[PlayAssetPackState._NAME_KEY]
	assert_true(did_succeed)
	assert_eq(pack_name, expected_pack_name)
	assert_asset_pack_state_eq_dict(result, expected_pack_state_dict)
	assert_eq(exception, null)

func test_get_asset_pack_state_error():
	var mock_plugin = FakeAndroidPlugin.new()
	
	var signal_info = FakePackStatesInfo.new(false, {}, \
		create_mock_asset_pack_java_lang_exception_dict())
	mock_plugin.set_fake_get_pack_states_info(signal_info)
	
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_pack_name = "random pack name"
	var request_object = test_object.get_asset_pack_state(test_pack_name)
	
	# connect to helper function, simulating the workflow of connecting callback to signal
	request_object.connect("request_completed", self, "assert_get_asset_pack_state_signal_is_error")
	
	# yield to the request_completed signal for no longer than 1 seconds and assert for signal emitted
	yield(yield_to(request_object, "request_completed", 1), YIELD)
	assert_signal_emitted(request_object, "request_completed", "signal should have emitted")
	
	# assert using getters, simulating the workflow of yielding the signals
	assert_true(not request_object.get_did_succeed())
	assert_eq(request_object.get_pack_name(), test_pack_name)
	assert_asset_pack_exception_eq_dict(request_object.get_error(), create_mock_asset_pack_java_lang_exception_dict())
	assert_eq(request_object.get_result(), null)
	
	# join instantiated thread
	signal_info.thread.wait_to_finish()

func assert_get_asset_pack_state_signal_is_error(did_succeed : bool, pack_name : String, \
	result : PlayAssetPackState, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	assert_true(not did_succeed)
	assert_eq(pack_name, "random pack name")
	assert_asset_pack_exception_eq_dict(exception, create_mock_asset_pack_java_lang_exception_dict())
	assert_eq(result, null)

func test_get_asset_pack_state_non_existent_pack():
	var mock_plugin = FakeAndroidPlugin.new()

	# configure what should be emitted upon get_asset_pack_state() call
	var test_asset_pack_state = create_mock_asset_pack_state_dict()
	var test_pack_name = test_asset_pack_state[PlayAssetPackState._NAME_KEY]
	
	# the plugin call will return an AssetPackStates dictionary enclosing the given test_asset_pack_state
	var test_asset_pack_states = create_mock_asset_pack_states_with_single_state_dict(test_asset_pack_state)
	var signal_info = FakePackStatesInfo.new(true, \
		test_asset_pack_states, {})
	mock_plugin.set_fake_get_pack_states_info(signal_info)
	
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	# AssetPackStates dictionary returned by plugin should not contain this pack_name
	var non_existent_pack_name = "non_existent_pack"
	var request_object = test_object.get_asset_pack_state(non_existent_pack_name)
	
	# connect to helper function, simulating the workflow of connecting callback to signal
	request_object.connect("request_completed", self, "assert_get_asset_pack_state_signal_non_existent_pack")
	
	# yield to the request_completed signal for no longer than 1 seconds and assert for signal emitted
	yield(yield_to(request_object, "request_completed", 1), YIELD)
	assert_signal_emitted(request_object, "request_completed", "signal should have emitted")
	
	# assert using getters, simulating the workflow of yielding the signals
	assert_true(not request_object.get_did_succeed())
	assert_eq(request_object.get_pack_name(), non_existent_pack_name)
	assert_eq(request_object.get_error(), null)
	assert_eq(request_object.get_result(), null)
	
	# join instantiated thread
	signal_info.thread.wait_to_finish()

func assert_get_asset_pack_state_signal_non_existent_pack(did_succeed : bool, pack_name : String, \
	result : PlayAssetPackState, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	assert_true(not did_succeed)
	assert_eq(pack_name, "non_existent_pack")
	assert_eq(result, null)
	assert_eq(exception, null)

func test_show_cellular_data_confirmation_success():
	var mock_plugin = FakeAndroidPlugin.new()

	# configure what should be emitted upon show_cellular_data_confirmation() call
	var signal_info = FakeCellularConfirmationInfo.new(true, PlayAssetPackManager.CellularDataConfirmationResult.RESULT_OK, {})
	mock_plugin.set_fake_cellular_confirmation_info(signal_info)
	
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var request_object = test_object.show_cellular_data_confirmation()
	
	# connect to helper function, simulating the workflow of connecting callback to signal
	request_object.connect("request_completed", self, "assert_show_cellular_data_confirmation_signal_is_success")
	
	# yield to the request_completed signal for no longer than 1 seconds and assert for signal emitted
	yield(yield_to(request_object, "request_completed", 1), YIELD)
	assert_signal_emitted(request_object, "request_completed", "signal should have emitted")
	
	# assert using getters, simulating the workflow of yielding the signals
	assert_true(request_object.get_did_succeed())
	assert_eq(request_object.get_error(), null)
	assert_eq(request_object.get_result(), PlayAssetPackManager.CellularDataConfirmationResult.RESULT_OK)
	
	# join instantiated thread
	signal_info.thread.wait_to_finish()

func assert_show_cellular_data_confirmation_signal_is_success(did_succeed : bool, result : int, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	assert_true(did_succeed)
	assert_eq(result, PlayAssetPackManager.CellularDataConfirmationResult.RESULT_OK)
	assert_eq(exception, null)

func test_show_cellular_data_confirmation_error():
	var mock_plugin = FakeAndroidPlugin.new()
	
	# configure what should be emitted upon show_cellular_data_confirmation() call
	var signal_info = FakeCellularConfirmationInfo.new(false, \
		PlayAssetPackManager.CellularDataConfirmationResult.RESULT_UNDEFINED, \
		create_mock_asset_pack_java_lang_exception_dict())
	mock_plugin.set_fake_cellular_confirmation_info(signal_info)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var request_object = test_object.show_cellular_data_confirmation()
	
	# connect to helper function, simulating the workflow of connecting callback to signal
	request_object.connect("request_completed", self, "assert_show_cellular_data_confirmation_signal_is_error")
	
	# yield to the request_completed signal for no longer than 1 seconds and assert for signal emitted
	yield(yield_to(request_object, "request_completed", 1), YIELD)
	assert_signal_emitted(request_object, "request_completed", "signal should have emitted")
	
	# assert using getters, simulating the workflow of yielding the signals
	assert_true(not request_object.get_did_succeed())
	assert_asset_pack_exception_eq_dict(request_object.get_error(), \
		create_mock_asset_pack_java_lang_exception_dict())
	assert_eq(request_object.get_result(), PlayAssetPackManager.CellularDataConfirmationResult.RESULT_UNDEFINED)
	# join instantiated thread
	signal_info.thread.wait_to_finish()

func assert_show_cellular_data_confirmation_signal_is_error(did_succeed : bool, result : int, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	assert_true(not did_succeed)
	assert_eq(result, PlayAssetPackManager.CellularDataConfirmationResult.RESULT_UNDEFINED)
	assert_asset_pack_exception_eq_dict(exception, create_mock_asset_pack_java_lang_exception_dict())

func test_remove_pack_success():
	var mock_plugin = FakeAndroidPlugin.new()

	# configure what should be emitted upon remove_pack() call
	var signal_info = FakeRemovePackInfo.new(true, {})
	mock_plugin.set_fake_remove_pack_info(signal_info)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var request_object = test_object.remove_pack("packName")
	
	# connect to helper function, simulating the workflow of connecting callback to signal
	request_object.connect("request_completed", self, "assert_remove_pack_signal_is_success")
	
	# yield to the request_completed signal for no longer than 1 seconds and assert for signal emitted
	yield(yield_to(request_object, "request_completed", 1), YIELD)
	assert_signal_emitted(request_object, "request_completed", "signal should have emitted")
	
	# assert using getters, simulating the workflow of yielding the signals
	assert_true(request_object.get_did_succeed())
	assert_eq(request_object.get_error(), null)
	
	# join instantiated thread
	signal_info.thread.wait_to_finish()

func assert_remove_pack_signal_is_success(did_succeed : bool, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	assert_true(did_succeed)
	assert_eq(exception, null)

func test_remove_pack_error():
	var mock_plugin = FakeAndroidPlugin.new()

	# configure what should be emitted upon remove_pack() call
	var signal_info = FakeRemovePackInfo.new(false, create_mock_asset_pack_java_lang_exception_dict())
	mock_plugin.set_fake_remove_pack_info(signal_info)
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var request_object = test_object.remove_pack("packName")
	
	# connect to helper function, simulating the workflow of connecting callback to signal
	request_object.connect("request_completed", self, "assert_remove_pack_signal_is_error")
	
	# yield to the request_completed signal for no longer than 1 seconds and assert for signal emitted
	yield(yield_to(request_object, "request_completed", 1), YIELD)
	assert_signal_emitted(request_object, "request_completed", "signal should have emitted")
	
	# assert using getters, simulating the workflow of yielding the signals
	assert_true(not request_object.get_did_succeed())
	assert_asset_pack_exception_eq_dict(request_object.get_error(), \
		create_mock_asset_pack_java_lang_exception_dict())

	# join instantiated thread
	signal_info.thread.wait_to_finish()

func assert_remove_pack_signal_is_error(did_succeed : bool, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	assert_true(not did_succeed)
	assert_asset_pack_exception_eq_dict(exception, \
		create_mock_asset_pack_java_lang_exception_dict())

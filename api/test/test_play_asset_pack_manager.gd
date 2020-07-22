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

func test_get_asset_pack_state_success():
	var mock_plugin = FakeAndroidPlugin.new()
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_pack_name = "pack1"
	var test_pack_status = PlayAssetPackManager.AssetPackStatus.DOWNLOADING
	
	var updated_asset_pack_state_dict = create_mock_asset_pack_state_with_status_dict(test_pack_name, test_pack_status)
	var fake_asset_pack_state_updated_handler = FakeAssetPackStateUpdatedHandler.new(updated_asset_pack_state_dict)
	# trigger mock assetPackStateUpdated signal
	mock_plugin.trigger_asset_pack_state_updated_signal(fake_asset_pack_state_updated_handler)
	# wait til the mock signal is emitted
	fake_asset_pack_state_updated_handler.thread.wait_to_finish()
	
	var result_asset_pack_state : PlayAssetPackState = test_object.get_asset_pack_state(test_pack_name)
	assert_asset_pack_state_eq_dict(result_asset_pack_state, updated_asset_pack_state_dict)

func test_get_asset_pack_state_changing_state():
	var mock_plugin = FakeAndroidPlugin.new()
	var test_object = create_play_asset_pack_manager(mock_plugin)
	
	var test_pack_name = "pack1"
	var test_pack_status1 = PlayAssetPackManager.AssetPackStatus.DOWNLOADING
	var test_pack_status2 = PlayAssetPackManager.AssetPackStatus.COMPLETED
	
	var updated_asset_pack_state_dict1 = create_mock_asset_pack_state_with_status_dict(test_pack_name, test_pack_status1)
	var updated_asset_pack_state_dict2 = create_mock_asset_pack_state_with_status_dict(test_pack_name, test_pack_status2)
	
	# emit first signal
	var fake_asset_pack_state_updated_handler = FakeAssetPackStateUpdatedHandler.new(updated_asset_pack_state_dict1)
	# trigger mock assetPackStateUpdated signal
	mock_plugin.trigger_asset_pack_state_updated_signal(fake_asset_pack_state_updated_handler)
	# wait til the mock signal is emitted
	fake_asset_pack_state_updated_handler.thread.wait_to_finish()

	# emit second signal
	fake_asset_pack_state_updated_handler = FakeAssetPackStateUpdatedHandler.new(updated_asset_pack_state_dict2)
	# trigger mock assetPackStateUpdated signal
	mock_plugin.trigger_asset_pack_state_updated_signal(fake_asset_pack_state_updated_handler)
	# wait til the mock signal is emitted
	fake_asset_pack_state_updated_handler.thread.wait_to_finish()
	
	var result_asset_pack_state : PlayAssetPackState = test_object.get_asset_pack_state(test_pack_name)
	assert_asset_pack_state_eq_dict(result_asset_pack_state, updated_asset_pack_state_dict2)
	
func test_get_asset_pack_state_non_existent_pack():
	var mock_plugin = FakeAndroidPlugin.new()
	var test_object = create_play_asset_pack_manager(mock_plugin)
	var result_asset_pack_state : PlayAssetPackState = test_object.get_asset_pack_state("non existing pack")
	assert_eq(result_asset_pack_state, null)

func test_show_cellular_data_confirmation_success():
	var mock_plugin = FakeAndroidPlugin.new()

	# configure what should be emitted upon show_cellular_data_confirmation() call
	var handler = FakeCellularConfirmationHandler.new(true, PlayAssetPackManager.CellularDataConfirmationResult.RESULT_OK, {})
	mock_plugin.set_fake_cellular_confirmation_handler(handler)
	
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
	handler.thread.wait_to_finish()

func assert_show_cellular_data_confirmation_signal_is_success(did_succeed : bool, result : int, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	assert_true(did_succeed)
	assert_eq(result, PlayAssetPackManager.CellularDataConfirmationResult.RESULT_OK)
	assert_eq(exception, null)

func test_show_cellular_data_confirmation_error():
	var mock_plugin = FakeAndroidPlugin.new()
	
	# configure what should be emitted upon show_cellular_data_confirmation() call
	var handler = FakeCellularConfirmationHandler.new(false, \
		PlayAssetPackManager.CellularDataConfirmationResult.RESULT_UNDEFINED, \
		create_mock_asset_pack_java_lang_exception_dict())
	mock_plugin.set_fake_cellular_confirmation_handler(handler)
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
	handler.thread.wait_to_finish()

func assert_show_cellular_data_confirmation_signal_is_error(did_succeed : bool, result : int, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	assert_true(not did_succeed)
	assert_eq(result, PlayAssetPackManager.CellularDataConfirmationResult.RESULT_UNDEFINED)
	assert_asset_pack_exception_eq_dict(exception, create_mock_asset_pack_java_lang_exception_dict())

func test_remove_pack_success():
	var mock_plugin = FakeAndroidPlugin.new()

	# configure what should be emitted upon remove_pack() call
	var handler = FakeRemovePackHandler.new(true, {})
	mock_plugin.set_fake_remove_pack_handler(handler)
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
	handler.thread.wait_to_finish()

func assert_remove_pack_signal_is_success(did_succeed : bool, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	assert_true(did_succeed)
	assert_eq(exception, null)

func test_remove_pack_error():
	var mock_plugin = FakeAndroidPlugin.new()

	# configure what should be emitted upon remove_pack() call
	var handler = FakeRemovePackHandler.new(false, create_mock_asset_pack_java_lang_exception_dict())
	mock_plugin.set_fake_remove_pack_handler(handler)
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
	handler.thread.wait_to_finish()

func assert_remove_pack_signal_is_error(did_succeed : bool, exception : PlayAssetPackException):
	# assert using callback, simulating the workflow of connecting callback to signal
	assert_true(not did_succeed)
	assert_asset_pack_exception_eq_dict(exception, \
		create_mock_asset_pack_java_lang_exception_dict())

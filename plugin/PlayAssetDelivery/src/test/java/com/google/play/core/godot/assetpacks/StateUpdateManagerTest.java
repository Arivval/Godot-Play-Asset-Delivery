/*
 *  	Copyright 2020 Google LLC
 *
 *  	Licensed under the Apache License, Version 2.0 (the "License");
 *  	you may not use this file except in compliance with the License.
 *  	You may obtain a copy of the License at
 *
 *  		https://www.apache.org/licenses/LICENSE-2.0
 *
 *  	Unless required by applicable law or agreed to in writing, software
 *  	distributed under the License is distributed on an "AS IS" BASIS,
 *  	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  	See the License for the specific language governing permissions and
 *  	limitations under the License.
 */

package com.google.play.core.godot.assetpacks;

import static com.google.common.truth.Truth.assertThat;
import static com.google.play.core.godot.assetpacks.PlayAssetDeliveryTestHelper.createAssetPackStateList;
import static org.junit.Assert.*;
import static org.mockito.Matchers.anyListOf;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.google.android.play.core.assetpacks.AssetPackManager;
import com.google.android.play.core.assetpacks.AssetPackState;
import com.google.android.play.core.assetpacks.AssetPackStates;
import com.google.android.play.core.tasks.Task;
import com.google.play.core.godot.assetpacks.utils.AssetPackStateFromDictionary;
import com.google.play.core.godot.assetpacks.utils.AssetPackStatesFromDictionary;
import com.google.play.core.godot.assetpacks.utils.PlayAssetDeliveryUtils;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import org.godotengine.godot.Dictionary;
import org.godotengine.godot.Godot;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class StateUpdateManagerTest {

  @Mock AssetPackManager assetPackManagerMock;
  @Mock Godot godotMock;

  @Test
  public void emitNonDuplicateStateUpdatedSignal_duplicateState() {
    ArgumentCaptor<String> signalNameCaptor = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<Object> signalArgsCaptor = ArgumentCaptor.forClass(Object.class);

    PlayAssetDelivery playAssetDelivery = new PlayAssetDelivery(godotMock, assetPackManagerMock);
    StateUpdateManager testStateUpdateManager =
        spy(new StateUpdateManager(playAssetDelivery, assetPackManagerMock));

    List<AssetPackState> assetPackStateList = createAssetPackStateList();

    // emit a stream of updates for same pack, but last two updates have duplicate states
    testStateUpdateManager.emitNonDuplicateStateUpdatedSignal(assetPackStateList.get(0), true);
    testStateUpdateManager.emitNonDuplicateStateUpdatedSignal(assetPackStateList.get(0), true);
    testStateUpdateManager.emitNonDuplicateStateUpdatedSignal(assetPackStateList.get(1), true);

    // assert times emitSignalWrapper() called
    int expect_signal_emit_times = 2;
    verify(testStateUpdateManager, times(expect_signal_emit_times))
        .emitSignalWrapper(signalNameCaptor.capture(), signalArgsCaptor.capture());
    // assert signal names
    assertThat(signalNameCaptor.getAllValues())
        .isEqualTo(
            Arrays.asList(
                PlayAssetDelivery.ASSET_PACK_STATE_UPDATED,
                PlayAssetDelivery.ASSET_PACK_STATE_UPDATED));
    // assert signal arguments
    List<Dictionary> expectedList =
        PlayAssetDeliveryTestHelper.createAssetPackStateList()
            .stream()
            .map(
                (AssetPackState state) ->
                    PlayAssetDeliveryUtils.convertAssetPackStateToDictionary(state))
            .collect(Collectors.toList())
            .subList(0, 2);
    assertThat(signalArgsCaptor.getAllValues()).isEqualTo(expectedList);
    // assert value of ongoingAssetPackRequests and updatedAssetPackStateMap
    String expectedPackName = assetPackStateList.get(0).name();
    assertThat(testStateUpdateManager.ongoingAssetPackRequests()).containsExactly(expectedPackName);
    Dictionary expectedUpdatedAssetPackStateDict =
        PlayAssetDeliveryUtils.convertAssetPackStateToDictionary(assetPackStateList.get(1));
    assertThat(testStateUpdateManager.updatedAssetPackStateMap()).hasSize(1);
    assertThat(testStateUpdateManager.updatedAssetPackStateMap())
        .containsEntry(expectedPackName, expectedUpdatedAssetPackStateDict);
  }

  @Test
  public void emitNonDuplicateStateUpdatedSignal_differentState() {
    ArgumentCaptor<String> signalNameCaptor = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<Object> signalArgsCaptor = ArgumentCaptor.forClass(Object.class);

    PlayAssetDelivery playAssetDelivery = new PlayAssetDelivery(godotMock, assetPackManagerMock);
    StateUpdateManager testStateUpdateManager =
        spy(new StateUpdateManager(playAssetDelivery, assetPackManagerMock));

    List<AssetPackState> assetPackStateList = createAssetPackStateList();

    testStateUpdateManager.emitNonDuplicateStateUpdatedSignal(assetPackStateList.get(0), false);
    testStateUpdateManager.emitNonDuplicateStateUpdatedSignal(assetPackStateList.get(1), false);
    testStateUpdateManager.emitNonDuplicateStateUpdatedSignal(assetPackStateList.get(2), false);

    // assert times emitSignalWrapper() called
    int expect_signal_emit_times = 3;
    verify(testStateUpdateManager, times(expect_signal_emit_times))
        .emitSignalWrapper(signalNameCaptor.capture(), signalArgsCaptor.capture());
    // assert signal names
    assertThat(signalNameCaptor.getAllValues())
        .isEqualTo(
            Arrays.asList(
                PlayAssetDelivery.ASSET_PACK_STATE_UPDATED,
                PlayAssetDelivery.ASSET_PACK_STATE_UPDATED,
                PlayAssetDelivery.ASSET_PACK_STATE_UPDATED));
    // assert signal arguments
    List<Dictionary> expectedList =
        PlayAssetDeliveryTestHelper.createAssetPackStateList()
            .stream()
            .map(PlayAssetDeliveryUtils::convertAssetPackStateToDictionary)
            .collect(Collectors.toList());
    assertThat(signalArgsCaptor.getAllValues()).isEqualTo(expectedList);
    // assert value of ongoingAssetPackRequests and updatedAssetPackStateMap
    assertThat(testStateUpdateManager.ongoingAssetPackRequests()).hasSize(0);
    String expectedPackName = assetPackStateList.get(0).name();
    Dictionary expectedUpdatedAssetPackStateDict =
        PlayAssetDeliveryUtils.convertAssetPackStateToDictionary(assetPackStateList.get(2));
    assertThat(testStateUpdateManager.updatedAssetPackStateMap()).hasSize(1);
    assertThat(testStateUpdateManager.updatedAssetPackStateMap())
        .containsEntry(expectedPackName, expectedUpdatedAssetPackStateDict);
  }

  @Test
  public void forceAssetPackStateUpdate_valid() {
    ArgumentCaptor<String> signalNameCaptor = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<Object> signalArgsCaptor = ArgumentCaptor.forClass(Object.class);

    PlayAssetDelivery playAssetDelivery = new PlayAssetDelivery(godotMock, assetPackManagerMock);
    StateUpdateManager testStateUpdateManager =
        spy(new StateUpdateManager(playAssetDelivery, assetPackManagerMock));

    Dictionary testDict = PlayAssetDeliveryTestHelper.createAssetPackStatesTestDictionary();
    AssetPackStates testAssetPackStates = new AssetPackStatesFromDictionary(testDict);
    Task<AssetPackStates> assetPackStatesSuccessTaskMock =
        PlayAssetDeliveryTestHelper.createMockOnSuccessTask(testAssetPackStates);
    when(assetPackManagerMock.getPackStates(anyListOf(String.class)))
        .thenReturn(assetPackStatesSuccessTaskMock);

    testStateUpdateManager.forceAssetPackStateUpdate();

    // assert times emitSignalWrapper() called
    int expect_signal_emit_times = 2;
    verify(testStateUpdateManager, times(expect_signal_emit_times))
        .emitSignalWrapper(signalNameCaptor.capture(), signalArgsCaptor.capture());
    // assert signal names
    assertThat(signalNameCaptor.getAllValues())
        .isEqualTo(
            Arrays.asList(
                PlayAssetDelivery.ASSET_PACK_STATE_UPDATED,
                PlayAssetDelivery.ASSET_PACK_STATE_UPDATED));
    // assert signal arguments
    Dictionary expectedPackStatesDict =
        (Dictionary) testDict.get(AssetPackStatesFromDictionary.PACK_STATES_KEY);
    List<Dictionary> expectedPackStateList =
        expectedPackStatesDict
            .values()
            .stream()
            .map(e -> (Dictionary) e)
            .collect(Collectors.toList());
    assertThat(signalArgsCaptor.getAllValues()).isEqualTo(expectedPackStateList);
    // assert value of ongoingAssetPackRequests and updatedAssetPackStateMap
    assertThat(testStateUpdateManager.ongoingAssetPackRequests()).hasSize(0);
    Dictionary expectedPackStateDict1 = expectedPackStateList.get(0);
    String expectedPackName1 =
        (String) expectedPackStateDict1.get(AssetPackStateFromDictionary.NAME_KEY);
    Dictionary expectedPackStateDict2 = expectedPackStateList.get(1);
    String expectedPackName2 =
        (String) expectedPackStateDict2.get(AssetPackStateFromDictionary.NAME_KEY);
    assertThat(testStateUpdateManager.updatedAssetPackStateMap()).hasSize(2);
    assertThat(testStateUpdateManager.updatedAssetPackStateMap())
        .containsEntry(expectedPackName1, expectedPackStateDict1);
    assertThat(testStateUpdateManager.updatedAssetPackStateMap())
        .containsEntry(expectedPackName2, expectedPackStateDict2);
  }

  @Test
  public void joinOngoingAssetPackRequests_valid() {
    PlayAssetDelivery playAssetDelivery = new PlayAssetDelivery(godotMock, assetPackManagerMock);
    StateUpdateManager testStateUpdateManager =
        new StateUpdateManager(playAssetDelivery, assetPackManagerMock);
    testStateUpdateManager.joinOngoingAssetPackRequests(Set.of("packName1", "packName2"));
    assertThat(testStateUpdateManager.ongoingAssetPackRequests())
        .containsExactly("packName1", "packName2");
    testStateUpdateManager.joinOngoingAssetPackRequests(Set.of("packName2", "packName3"));
    assertThat(testStateUpdateManager.ongoingAssetPackRequests())
        .containsExactly("packName1", "packName2", "packName3");
  }
}

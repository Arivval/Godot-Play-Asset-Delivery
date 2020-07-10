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
import static org.mockito.Matchers.any;
import static org.mockito.Matchers.anyListOf;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import com.google.android.play.core.assetpacks.AssetPackManager;
import com.google.android.play.core.assetpacks.AssetPackStates;
import com.google.android.play.core.tasks.Task;
import com.google.play.core.godot.assetpacks.utils.AssetLocationFromDictionary;
import com.google.play.core.godot.assetpacks.utils.AssetPackLocationFromDictionary;
import com.google.play.core.godot.assetpacks.utils.AssetPackStatesFromDictionary;
import com.google.play.core.godot.assetpacks.utils.PlayAssetDeliveryUtils;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import org.godotengine.godot.Dictionary;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.SignalInfo;
import org.junit.*;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class PlayAssetDeliveryTest {

  @Mock Godot godotMock;
  @Mock AssetPackManager assetPackManagerMock;

  /** Creates a mock PlayAssetDelivery instance with mock objects. */
  private PlayAssetDelivery createPlayAssetDeliveryInstance() {
    return new PlayAssetDelivery(godotMock, assetPackManagerMock);
  }

  @Test
  public void getPluginName() {
    PlayAssetDelivery testSubject = createPlayAssetDeliveryInstance();
    String actualName = testSubject.getPluginName();
    assertThat(actualName).isEqualTo("PlayAssetDelivery");
  }

  @Test
  public void getPluginMethods() {
    PlayAssetDelivery testSubject = createPlayAssetDeliveryInstance();
    List<String> actualList = testSubject.getPluginMethods();
    assertThat(actualList)
        .containsExactly(
            "cancel",
            "fetch",
            "getAssetLocation",
            "getPackLocation",
            "getPackLocations",
            "getPackStates",
            "removePack",
            "showCellularDataConfirmation");
  }

  @Test
  public void getPluginSignals() {
    PlayAssetDelivery testSubject = createPlayAssetDeliveryInstance();
    Set<SignalInfo> testSet = testSubject.getPluginSignals();

    SignalInfo assetPackStateUpdateSignal =
        new SignalInfo("assetPackStateUpdated", Dictionary.class);
    SignalInfo fetchStateUpdated =
        new SignalInfo("fetchStateUpdated", Dictionary.class, Integer.class);
    SignalInfo fetchSuccess = new SignalInfo("fetchSuccess", Dictionary.class, Integer.class);
    SignalInfo fetchError = new SignalInfo("fetchError", String.class, Integer.class);
    SignalInfo getPackStatesSuccess =
        new SignalInfo("getPackStatesSuccess", Dictionary.class, Integer.class);
    SignalInfo getPackStatesError =
        new SignalInfo("getPackStatesError", String.class, Integer.class);
    SignalInfo removePackSuccess = new SignalInfo("removePackSuccess", String.class, Integer.class);
    SignalInfo removePackError =
        new SignalInfo("removePackError", String.class, String.class, Integer.class);
    SignalInfo showCellularDataConfirmationSuccess =
        new SignalInfo("showCellularDataConfirmationSuccess", Integer.class, Integer.class);
    SignalInfo showCellularDataConfirmationError =
        new SignalInfo("showCellularDataConfirmationError", String.class, Integer.class);
    assertThat(testSet)
        .containsExactly(
            assetPackStateUpdateSignal,
            fetchStateUpdated,
            fetchSuccess,
            fetchError,
            getPackStatesSuccess,
            getPackStatesError,
            removePackSuccess,
            removePackError,
            showCellularDataConfirmationSuccess,
            showCellularDataConfirmationError);
  }

  @Test
  public void cancel_success() {
    PlayAssetDelivery testSubject = createPlayAssetDeliveryInstance();
    String[] testPackNames = {"Test pack 1", "Test pack 2"};
    Dictionary testDict = PlayAssetDeliveryTestHelper.createAssetPackStatesTestDictionary();

    when(assetPackManagerMock.cancel(anyListOf(String.class)))
        .thenReturn(new AssetPackStatesFromDictionary(testDict));

    Dictionary resultDict = testSubject.cancel(testPackNames);
    assertThat(resultDict).isEqualTo(testDict);
  }

  @Test
  public void getAssetLocation_exist() {
    PlayAssetDelivery testSubject = createPlayAssetDeliveryInstance();
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetLocationDictionary(0, "~/Documents/", 256);

    when(assetPackManagerMock.getAssetLocation(any(String.class), any(String.class)))
        .thenReturn(new AssetLocationFromDictionary(testDict));

    Dictionary resultDict = testSubject.getAssetLocation("packName", "assetPath");
    assertThat(resultDict).isEqualTo(testDict);
  }

  @Test
  public void getAssetLocation_notExist() {
    PlayAssetDelivery testSubject = createPlayAssetDeliveryInstance();

    when(assetPackManagerMock.getAssetLocation(any(String.class), any(String.class)))
        .thenReturn(null);

    Dictionary resultDict = testSubject.getAssetLocation("packName", "assetPath");
    assertThat(resultDict).isEqualTo(null);
  }

  @Test
  public void getPackLocation_exist() {
    PlayAssetDelivery testSubject = createPlayAssetDeliveryInstance();
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Documents/assetsPath/", 0, "~/Documents/path/");

    when(assetPackManagerMock.getPackLocation(any(String.class)))
        .thenReturn(new AssetPackLocationFromDictionary(testDict));

    Dictionary resultDict = testSubject.getPackLocation("packName");
    assertThat(resultDict).isEqualTo(testDict);
  }

  @Test
  public void getPackLocation_notExist() {
    PlayAssetDelivery testSubject = createPlayAssetDeliveryInstance();

    when(assetPackManagerMock.getPackLocation(any(String.class))).thenReturn(null);

    Dictionary resultDict = testSubject.getPackLocation("packName");
    assertThat(resultDict).isEqualTo(null);
  }

  @Test
  public void getPackLocations_success() {
    PlayAssetDelivery testSubject = createPlayAssetDeliveryInstance();
    Dictionary testDict = PlayAssetDeliveryTestHelper.createAssetPackLocationsDictionary();

    when(assetPackManagerMock.getPackLocations())
        .thenReturn(PlayAssetDeliveryUtils.convertDictionaryToAssetPackLocations(testDict));

    Dictionary resultDict = testSubject.getPackLocations();
    assertThat(resultDict).isEqualTo(testDict);
  }

  @Test
  public void getPackStates_success() {
    // Mock the side effects of Task<AssetPackStates> object, call onSuccessListener the instant
    // it is registered.
    Dictionary testDict = PlayAssetDeliveryTestHelper.createAssetPackStatesTestDictionary();
    AssetPackStates testAssetPackStates = new AssetPackStatesFromDictionary(testDict);

    Task<AssetPackStates> assetPackStatesSuccessTaskMock =
        PlayAssetDeliveryTestHelper.createMockOnSuccessTask(testAssetPackStates);

    PlayAssetDelivery testSubject = spy(new PlayAssetDelivery(godotMock, assetPackManagerMock));
    when(assetPackManagerMock.getPackStates(anyListOf(String.class)))
        .thenReturn(assetPackStatesSuccessTaskMock);

    // Set up ArgumentCaptors to get the arguments received by emitSignalWrapper()
    ArgumentCaptor<String> signalNameCaptor = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<Object> signalArgsCaptor = ArgumentCaptor.forClass(Object.class);

    testSubject.getPackStates(Arrays.asList("pack1", "pack2"), 14);

    verify(testSubject).emitSignalWrapper(signalNameCaptor.capture(), signalArgsCaptor.capture());

    assertThat(signalNameCaptor.getValue()).isEqualTo("getPackStatesSuccess");
    List<Object> receivedArgs = signalArgsCaptor.getAllValues();
    assertThat(receivedArgs).hasSize(2);

    assertThat(receivedArgs.get(0)).isEqualTo(testDict);
    assertThat(receivedArgs.get(1)).isEqualTo(14);
  }

  @Test
  public void getPackStates_error() {
    // Mock the side effects of Task<AssetPackStates> object, call onFailureListener the instant
    // it is registered.
    Exception testException = new Exception("Test Exception!");
    Task<AssetPackStates> assetPackStatesFailureTaskMock =
        PlayAssetDeliveryTestHelper.createMockOnFailureTask(testException);

    PlayAssetDelivery testSubject = spy(new PlayAssetDelivery(godotMock, assetPackManagerMock));
    when(assetPackManagerMock.getPackStates(anyListOf(String.class)))
        .thenReturn(assetPackStatesFailureTaskMock);

    // Set up ArgumentCaptors to get the arguments received by emitSignalWrapper()
    ArgumentCaptor<String> signalNameCaptor = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<Object> signalArgsCaptor = ArgumentCaptor.forClass(Object.class);

    testSubject.getPackStates(Arrays.asList("pack1", "pack2"), 15);

    verify(testSubject).emitSignalWrapper(signalNameCaptor.capture(), signalArgsCaptor.capture());

    assertThat(signalNameCaptor.getValue()).isEqualTo("getPackStatesError");
    List<Object> receivedArgs = signalArgsCaptor.getAllValues();
    assertThat(receivedArgs).hasSize(2);
    assertThat(receivedArgs.get(0)).isEqualTo("java.lang.Exception: Test Exception!");
    assertThat(receivedArgs.get(1)).isEqualTo(15);
  }

  @Test
  public void removePack_success() {
    // Mock the side effects of Task<Void> object, call onSuccessListener the instant
    // it is registered.
    Task<Void> voidSuccessTaskMock = PlayAssetDeliveryTestHelper.createMockOnSuccessTask(null);

    PlayAssetDelivery testSubject = spy(new PlayAssetDelivery(godotMock, assetPackManagerMock));
    when(assetPackManagerMock.removePack(any(String.class))).thenReturn(voidSuccessTaskMock);

    // Set up ArgumentCaptors to get the arguments received by emitSignalWrapper()
    ArgumentCaptor<String> signalNameCaptor = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<Object> signalArgsCaptor = ArgumentCaptor.forClass(Object.class);

    testSubject.removePack("packName", 10);

    verify(testSubject).emitSignalWrapper(signalNameCaptor.capture(), signalArgsCaptor.capture());

    assertThat(signalNameCaptor.getValue()).isEqualTo("removePackSuccess");
    List<Object> receivedArgs = signalArgsCaptor.getAllValues();
    assertThat(receivedArgs).hasSize(1);
    assertThat(receivedArgs.get(0)).isEqualTo(10);
  }

  @Test
  public void removePack_error() {
    // Mock the side effects of Task<Void> object, call onFailureListener the instant
    // it is registered.
    Exception testException = new Exception("Test Exception!");
    Task<Void> voidFailureTaskMock =
        PlayAssetDeliveryTestHelper.createMockOnFailureTask(testException);

    PlayAssetDelivery testSubject = spy(new PlayAssetDelivery(godotMock, assetPackManagerMock));
    when(assetPackManagerMock.removePack(any(String.class))).thenReturn(voidFailureTaskMock);

    // Set up ArgumentCaptors to get the arguments received by emitSignalWrapper()
    ArgumentCaptor<String> signalNameCaptor = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<Object> signalArgsCaptor = ArgumentCaptor.forClass(Object.class);

    testSubject.removePack("packName", 11);

    verify(testSubject).emitSignalWrapper(signalNameCaptor.capture(), signalArgsCaptor.capture());

    assertThat(signalNameCaptor.getValue()).isEqualTo("removePackError");
    List<Object> receivedArgs = signalArgsCaptor.getAllValues();
    assertThat(receivedArgs).hasSize(2);
    assertThat(receivedArgs.get(0)).isEqualTo("java.lang.Exception: Test Exception!");
    assertThat(receivedArgs.get(1)).isEqualTo(11);
  }

  @Test
  public void showCellularDataConfirmation_success() {
    // Mock the side effects of Task<Integer> object, call onSuccessListener the instant
    // it is registered.
    Task<Integer> integerSuccessTaskMock = PlayAssetDeliveryTestHelper.createMockOnSuccessTask(1);

    PlayAssetDelivery testSubject = spy(new PlayAssetDelivery(godotMock, assetPackManagerMock));
    when(assetPackManagerMock.showCellularDataConfirmation(any(Activity.class)))
        .thenReturn(integerSuccessTaskMock);

    // Set up ArgumentCaptors to get the arguments received by emitSignalWrapper()
    ArgumentCaptor<String> signalNameCaptor = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<Object> signalArgsCaptor = ArgumentCaptor.forClass(Object.class);

    testSubject.showCellularDataConfirmation(12);

    verify(testSubject).emitSignalWrapper(signalNameCaptor.capture(), signalArgsCaptor.capture());

    assertThat(signalNameCaptor.getValue()).isEqualTo("showCellularDataConfirmationSuccess");
    List<Object> receivedArgs = signalArgsCaptor.getAllValues();
    assertThat(receivedArgs).hasSize(2);
    assertThat(receivedArgs.get(0)).isEqualTo(1);
    assertThat(receivedArgs.get(1)).isEqualTo(12);
  }

  @Test
  public void showCellularDataConfirmation_error() {
    // Mock the side effects of Task<Integer> object, call onFailureListener the instant
    // it is registered.
    Exception testException = new Exception("Test Exception!");
    Task<Integer> integerFailureTaskMock =
        PlayAssetDeliveryTestHelper.createMockOnFailureTask(testException);

    PlayAssetDelivery testSubject = spy(new PlayAssetDelivery(godotMock, assetPackManagerMock));
    when(assetPackManagerMock.showCellularDataConfirmation(any(Activity.class)))
        .thenReturn(integerFailureTaskMock);

    // Set up ArgumentCaptors to get the arguments received by emitSignalWrapper()
    ArgumentCaptor<String> signalNameCaptor = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<Object> signalArgsCaptor = ArgumentCaptor.forClass(Object.class);

    testSubject.showCellularDataConfirmation(13);

    verify(testSubject).emitSignalWrapper(signalNameCaptor.capture(), signalArgsCaptor.capture());

    assertThat(signalNameCaptor.getValue()).isEqualTo("showCellularDataConfirmationError");
    List<Object> receivedArgs = signalArgsCaptor.getAllValues();
    assertThat(receivedArgs).hasSize(2);
    assertThat(receivedArgs.get(0)).isEqualTo("java.lang.Exception: Test Exception!");
    assertThat(receivedArgs.get(1)).isEqualTo(13);
  }
}

/*
 *  	Copyright 2020 Google LLC
 *  	Licensed under the Apache License, Version 2.0 (the "License");
 *  	you may not use this file except in compliance with the License.
 *  	You may obtain a copy of the License at
 *  		https://www.apache.org/licenses/LICENSE-2.0
 *  	Unless required by applicable law or agreed to in writing, software
 *  	distributed under the License is distributed on an "AS IS" BASIS,
 *  	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  	See the License for the specific language governing permissions and
 *  	limitations under the License.
 */

package com.google.play.core.godot.assetpacks;

import static com.google.common.truth.Truth.assertThat;

import java.util.List;
import java.util.Set;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.SignalInfo;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class PlayAssetDeliveryTest {

  @Mock Godot godotMock;

  @Test
  public void getPluginName() {
    PlayAssetDelivery testSubject = new PlayAssetDelivery(godotMock);
    String actualName = testSubject.getPluginName();
    assertThat(actualName).isEqualTo("PlayAssetDelivery");
  }

  @Test
  public void getPluginMethods() {
    PlayAssetDelivery testSubject = new PlayAssetDelivery(godotMock);
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
    PlayAssetDelivery testSubject = new PlayAssetDelivery(godotMock);
    Set<SignalInfo> testSet = testSubject.getPluginSignals();

    SignalInfo assetPackStateUpdateSignal =
        new SignalInfo("assetPackStateUpdateSignal", String.class);
    SignalInfo fetchStateUpdated = new SignalInfo("fetchStateUpdated", String.class, Integer.class);
    SignalInfo fetchSuccess = new SignalInfo("fetchSuccess", String.class, Integer.class);
    SignalInfo fetchError = new SignalInfo("fetchError", String.class, Integer.class);
    SignalInfo getPackStatesSuccess =
        new SignalInfo("getPackStatesSuccess", String.class, Integer.class);
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
}

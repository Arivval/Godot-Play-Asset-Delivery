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

package com.google.play.core.godot.assetpacks.utils;

import static com.google.common.truth.Truth.assertThat;

import com.google.android.play.core.assetpacks.AssetLocation;
import com.google.android.play.core.assetpacks.AssetPackState;
import org.godotengine.godot.Dictionary;
import org.junit.Test;

public class PlayAssetDeliveryUtilsTest {

  @Test
  public void convertAssetPackStateToDictionaryAndBack_valid1() {
    Dictionary testDictionary =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    AssetPackState testAssetPackState =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary);
    Dictionary resultingDictionary =
        PlayAssetDeliveryUtils.convertAssetPackStateToDictionary(testAssetPackState);
    assertThat(resultingDictionary).isEqualTo(testDictionary);
  }

  @Test
  public void convertAssetPackStateToDictionaryAndBack_valid2() {
    Dictionary testDictionary =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            0, -6, "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", 7, 0, 0);
    AssetPackState testAssetPackState =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary);
    Dictionary resultingDictionary =
        PlayAssetDeliveryUtils.convertAssetPackStateToDictionary(testAssetPackState);
    assertThat(resultingDictionary).isEqualTo(testDictionary);
  }

  @Test(expected = IllegalArgumentException.class)
  public void convertDictionaryToAssetPackState_missingKey() {
    // Test failure case where there is a missing key
    Dictionary testDictionary =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    testDictionary.remove("bytesDownloaded");
    AssetPackState testAssetPackState =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary);
  }

  @Test(expected = IllegalArgumentException.class)
  public void convertDictionaryToAssetPackState_typeMismatch() {
    // Test failure case where there is a type mismatch
    Dictionary testDictionary =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    testDictionary.put("bytesDownloaded", "PAD");
    AssetPackState testAssetPackState =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary);
  }

  @Test
  public void convertAssetLocationToDictionaryAndBack_valid1() {
    Dictionary testDictionary =
            PlayAssetDeliveryUtils.constructAssetLocationDictionary(42, "~/Downloads/dlc.pck", 65536);
    AssetLocation testAssetLocation =
            PlayAssetDeliveryUtils.convertDictionaryToAssetLocation(testDictionary);
    Dictionary resultingDictionary =
            PlayAssetDeliveryUtils.convertAssetLocationToDictionary(testAssetLocation);
    assertThat(resultingDictionary).isEqualTo(testDictionary);
  }

  @Test
  public void convertAssetLocationToDictionaryAndBack_valid2() {
    Dictionary testDictionary =
            PlayAssetDeliveryUtils.constructAssetLocationDictionary(
                    0,
                    "~/Documents/Godot-Play-Asset-Delivery/plugin/PlayAssetDelivery/src/test/java/com/google/play/core/godot/assetpacks/utils/dlc.pck",
                    42);
    AssetLocation testAssetLocation =
            PlayAssetDeliveryUtils.convertDictionaryToAssetLocation(testDictionary);
    Dictionary resultingDictionary =
            PlayAssetDeliveryUtils.convertAssetLocationToDictionary(testAssetLocation);
    assertThat(resultingDictionary).isEqualTo(testDictionary);
  }

  @Test(expected = IllegalArgumentException.class)
  public void convertDictionaryToAssetLocation_missingKey() {
    // Test failure case where there is a missing key
    Dictionary testDictionary =
            PlayAssetDeliveryUtils.constructAssetLocationDictionary(42, "~/Downloads/dlc.pck", 65536);
    testDictionary.remove("size");
    AssetLocation testAssetLocation =
            PlayAssetDeliveryUtils.convertDictionaryToAssetLocation(testDictionary);
  }

  @Test(expected = IllegalArgumentException.class)
  public void convertDictionaryToAssetLocation_typeMismatch() {
    // Test failure case where there is a type mismatch
    Dictionary testDictionary =
            PlayAssetDeliveryUtils.constructAssetLocationDictionary(42, "~/Downloads/dlc.pck", 65536);
    testDictionary.put("offset", "invalid type");
    AssetLocation testAssetLocation =
            PlayAssetDeliveryUtils.convertDictionaryToAssetLocation(testDictionary);
  }
}

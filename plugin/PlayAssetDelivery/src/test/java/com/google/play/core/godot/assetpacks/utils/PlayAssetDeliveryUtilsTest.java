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
import com.google.android.play.core.assetpacks.AssetPackException;
import com.google.android.play.core.assetpacks.AssetPackLocation;
import com.google.android.play.core.assetpacks.AssetPackState;
import com.google.android.play.core.assetpacks.AssetPackStates;
import com.google.play.core.godot.assetpacks.PlayAssetDeliveryTestHelper;
import java.util.Map;
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
    testDictionary.remove(AssetPackStateFromDictionary.BYTES_DOWNLOADED_KEY);
    AssetPackState testAssetPackState =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary);
  }

  @Test(expected = IllegalArgumentException.class)
  public void convertDictionaryToAssetPackState_typeMismatch() {
    // Test failure case where there is a type mismatch
    Dictionary testDictionary =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    testDictionary.put(AssetPackStateFromDictionary.BYTES_DOWNLOADED_KEY, "PAD");
    AssetPackState testAssetPackState =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary);
  }

  @Test
  public void convertAssetPackStatesToDictionaryAndBack_valid1() {
    Dictionary innerDict1 =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    Dictionary innerDict2 =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            0, -6, "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", 7, 0, 0);
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackStatesDictionary(65536, new Dictionary());
    PlayAssetDeliveryUtils.appendToAssetPackStatesDictionary(testDict, "pack1", innerDict1);
    PlayAssetDeliveryUtils.appendToAssetPackStatesDictionary(testDict, "pack2", innerDict2);

    AssetPackStates testSubject = new AssetPackStatesFromDictionary(testDict);
    Dictionary resultingDictionary =
        PlayAssetDeliveryUtils.convertAssetPackStatesToDictionary(testSubject);
    assertThat(resultingDictionary).isEqualTo(testDict);
  }

  @Test
  public void convertAssetPackStatesToDictionaryAndBack_valid2() {
    Dictionary innerDict1 =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackStatesDictionary(65536, new Dictionary());
    PlayAssetDeliveryUtils.appendToAssetPackStatesDictionary(testDict, "pack1", innerDict1);

    AssetPackStates testSubject = new AssetPackStatesFromDictionary(testDict);
    Dictionary resultingDictionary =
        PlayAssetDeliveryUtils.convertAssetPackStatesToDictionary(testSubject);
    assertThat(resultingDictionary).isEqualTo(testDict);
  }

  @Test(expected = IllegalArgumentException.class)
  public void convertDictionaryToAssetPackStates_missingKey() {
    // Test failure case where there is a missing key
    Dictionary innerDict1 =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackStatesDictionary(65536, new Dictionary());
    PlayAssetDeliveryUtils.appendToAssetPackStatesDictionary(testDict, "pack1", innerDict1);

    testDict.remove(AssetPackStatesFromDictionary.TOTAL_BYTES_KEY);

    AssetPackStates testAssetPackStates =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackStates(testDict);
  }

  @Test(expected = IllegalArgumentException.class)
  public void convertDictionaryToAssetPackStates_typeMismatch() {
    // Test failure case where there is a type mismatch
    Dictionary innerDict1 =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackStatesDictionary(65536, new Dictionary());
    PlayAssetDeliveryUtils.appendToAssetPackStatesDictionary(testDict, "pack1", innerDict1);

    testDict.put(AssetPackStatesFromDictionary.TOTAL_BYTES_KEY, "wrong key");

    AssetPackStates testAssetPackStates =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackStates(testDict);
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
    testDictionary.remove(AssetLocationFromDictionary.SIZE_KEY);
    AssetLocation testAssetLocation =
        PlayAssetDeliveryUtils.convertDictionaryToAssetLocation(testDictionary);
  }

  @Test(expected = IllegalArgumentException.class)
  public void convertDictionaryToAssetLocation_typeMismatch() {
    // Test failure case where there is a type mismatch
    Dictionary testDictionary =
        PlayAssetDeliveryUtils.constructAssetLocationDictionary(42, "~/Downloads/dlc.pck", 65536);
    testDictionary.put(AssetLocationFromDictionary.OFFSET_KEY, "invalid type");
    AssetLocation testAssetLocation =
        PlayAssetDeliveryUtils.convertDictionaryToAssetLocation(testDictionary);
  }

  @Test
  public void convertAssetPackLocationToDictionaryAndBack_valid1() {
    Dictionary testDictionary =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Downloads/assetsPath", 0, "~/Downloads/extractedPath");
    AssetPackLocation testAssetPackLocation =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackLocation(testDictionary);
    Dictionary resultingDictionary =
        PlayAssetDeliveryUtils.convertAssetPackLocationToDictionary(testAssetPackLocation);
    assertThat(resultingDictionary).isEqualTo(testDictionary);
  }

  @Test
  public void convertAssetPackLocationToDictionaryAndBack_valid2() {
    Dictionary testDictionary =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Documents/Godot-Play-Asset-Delivery/plugin/PlayAssetDelivery/src/test/java/com/google/play/core/godot/assetpacks/utils/assetsPath",
            0,
            "~/Documents/Godot-Play-Asset-Delivery/plugin/PlayAssetDelivery/src/test/java/com/google/play/core/godot/assetpacks/utils/extractedPath");
    AssetPackLocation testAssetPackLocation =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackLocation(testDictionary);
    Dictionary resultingDictionary =
        PlayAssetDeliveryUtils.convertAssetPackLocationToDictionary(testAssetPackLocation);
    assertThat(resultingDictionary).isEqualTo(testDictionary);
  }

  @Test(expected = IllegalArgumentException.class)
  public void convertDictionaryToAssetPackLocation_missingKey() {
    // Test failure case where there is a missing key
    Dictionary testDictionary =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Downloads/assetsPath", 0, "~/Downloads/extractedPath");
    testDictionary.remove(AssetPackLocationFromDictionary.PATH_KEY);
    AssetPackLocation testAssetPackLocation =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackLocation(testDictionary);
  }

  @Test(expected = IllegalArgumentException.class)
  public void convertDictionaryToAssetPackLocation_typeMismatch() {
    // Test failure case where there is a type mismatch
    Dictionary testDictionary =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Downloads/assetsPath", 0, "~/Downloads/extractedPath");
    testDictionary.put(AssetPackLocationFromDictionary.PATH_KEY, 123);
    AssetPackLocation testAssetPackLocation =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackLocation(testDictionary);
  }

  @Test
  public void convertAssetPackLocationsToDictionaryAndBack_valid() {
    Dictionary testDictionary = PlayAssetDeliveryTestHelper.createAssetPackLocationsDictionary();

    Map<String, AssetPackLocation> testAssetPackLocations =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackLocations(testDictionary);
    Dictionary resultingDictionary =
        PlayAssetDeliveryUtils.convertAssetPackLocationsToDictionary(testAssetPackLocations);
    assertThat(resultingDictionary).isEqualTo(testDictionary);
  }

  @Test(expected = IllegalArgumentException.class)
  public void convertDictionaryToAssetPackLocations_missingKey() {
    // Test failure case where there is a missing key
    Dictionary innerDict =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Downloads/assetsPath", 0, "~/Downloads/extractedPath");
    Dictionary testDictionary = new Dictionary();
    testDictionary.put("location1", innerDict);

    innerDict.remove(AssetPackLocationFromDictionary.ASSETS_PATH_KEY);

    Map<String, AssetPackLocation> testAssetPackLocations =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackLocations(testDictionary);
  }

  @Test(expected = IllegalArgumentException.class)
  public void convertDictionaryToAssetPackLocations_typeMismatch1() {
    // Test failure case where there is a type mismatch
    Dictionary innerDict =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Downloads/assetsPath", 0, "~/Downloads/extractedPath");
    Dictionary testDictionary = new Dictionary();
    testDictionary.put("location1", innerDict);

    innerDict.put(AssetPackLocationFromDictionary.ASSETS_PATH_KEY, -1);

    Map<String, AssetPackLocation> testAssetPackLocations =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackLocations(testDictionary);
  }

  @Test(expected = IllegalArgumentException.class)
  public void convertDictionaryToAssetPackLocations_typeMismatch2() {
    // Test failure case where there is a type mismatch
    Dictionary innerDict =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Downloads/assetsPath", 0, "~/Downloads/extractedPath");
    Dictionary testDictionary = new Dictionary();
    testDictionary.put("location1", "innerDict");

    Map<String, AssetPackLocation> testAssetPackLocations =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackLocations(testDictionary);
  }

  @Test
  public void convertExceptionToDictionary_regularException() {
    Exception testException = new Exception("Just testing, don't panic.");
    Dictionary testDict = PlayAssetDeliveryUtils.convertExceptionToDictionary(testException);

    Dictionary expectedDict = new Dictionary();
    expectedDict.put("toString", "java.lang.Exception: Just testing, don't panic.");

    assertThat(testDict).isEqualTo(expectedDict);
  }

  @Test
  public void convertExceptionToDictionary_assetPackException() {
    AssetPackException testException = PlayAssetDeliveryTestHelper.createMockAssetPackException();
    Dictionary testDict = PlayAssetDeliveryUtils.convertExceptionToDictionary(testException);

    Dictionary expectedDict = new Dictionary();
    expectedDict.put("toString", "java.lang.RuntimeException.AssetPackException: testException!");
    expectedDict.put("errorCode", -7);

    assertThat(testDict).isEqualTo(expectedDict);
  }
}

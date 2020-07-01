package com.google.play.core.godot.assetpacks.utils;

import static com.google.common.truth.Truth.assertThat;

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

  @Test
  public void convertDictionaryToAssetPackState_missingKey() {
    // Test failure case where there is a missing key
    Dictionary testDictionary =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    testDictionary.remove("bytesDownloaded");
    AssetPackState testAssetPackState =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary);
    assertThat(testAssetPackState).isEqualTo(null);
  }

  @Test
  public void convertDictionaryToAssetPackState_typeMismatch() {
    // Test failure case where there is a missing key
    Dictionary testDictionary =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    testDictionary.put("bytesDownloaded", "PAD");
    AssetPackState testAssetPackState =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary);
    assertThat(testAssetPackState).isEqualTo(null);
  }
}

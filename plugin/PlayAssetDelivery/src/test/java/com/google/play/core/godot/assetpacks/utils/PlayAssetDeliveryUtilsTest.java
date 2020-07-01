package com.google.play.core.godot.assetpacks.utils;

import static com.google.common.truth.Truth.assertThat;

import com.google.android.play.core.assetpacks.AssetPackState;

import org.godotengine.godot.Dictionary;
import org.junit.Test;

public class PlayAssetDeliveryUtilsTest {
  private Dictionary constructAssetPackStateDictionaryHelper(
      long bytesDownloaded,
      int errorCode,
      String name,
      int status,
      long totalBytesToDownload,
      int transferProgressPercentage) {
    Dictionary returnDict = new Dictionary();
    returnDict.put("bytesDownloaded", bytesDownloaded);
    returnDict.put("errorCode", errorCode);
    returnDict.put("name", name);
    returnDict.put("status", status);
    returnDict.put("totalBytesToDownload", totalBytesToDownload);
    returnDict.put("transferProgressPercentage", transferProgressPercentage);
    return returnDict;
  }

  private Dictionary constructAssetLocationDictionaryHelper(long offset, String path, long size) {
    Dictionary returnDict = new Dictionary();
    returnDict.put("offset", offset);
    returnDict.put("path", path);
    returnDict.put("size", size);
    return returnDict;
  }

  private Dictionary constructAssetPackLocationDictionaryHelper(
      String assetsPath, int packStorageMethod, String path) {
    Dictionary returnDict = new Dictionary();
    returnDict.put("assetsPath", assetsPath);
    returnDict.put("packStorageMethod", packStorageMethod);
    returnDict.put("path", path);
    return returnDict;
  }

  @Test
  public void testAssetPackStateSerialization1() {
    Dictionary testDictionary =
        constructAssetPackStateDictionaryHelper(42, 0, "awesomePack", 2, 65536, 35);
    AssetPackState testAssetPackState =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary);
    Dictionary resultingDictionary =
        PlayAssetDeliveryUtils.convertAssetPackStateToDictionary(testAssetPackState);
    assertThat(resultingDictionary).isEqualTo(testDictionary);
  }

  @Test
  public void testAssetPackStateSerialization2() {
    Dictionary testDictionary =
        constructAssetPackStateDictionaryHelper(
            0, -6, "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", 7, 0, 0);
    AssetPackState testAssetPackState =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary);
    Dictionary resultingDictionary =
        PlayAssetDeliveryUtils.convertAssetPackStateToDictionary(testAssetPackState);
    assertThat(resultingDictionary).isEqualTo(testDictionary);
  }

  @Test
  public void testAssetPackStateSerialization3() {
    // Test failure case where there is a missing key
    Dictionary testDictionary =
        constructAssetPackStateDictionaryHelper(42, 0, "awesomePack", 2, 65536, 35);
    testDictionary.remove("bytesDownloaded");
    AssetPackState testAssetPackState =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary);
    Dictionary resultingDictionary =
        PlayAssetDeliveryUtils.convertAssetPackStateToDictionary(testAssetPackState);
    assertThat(resultingDictionary).isEqualTo(null);
  }
}

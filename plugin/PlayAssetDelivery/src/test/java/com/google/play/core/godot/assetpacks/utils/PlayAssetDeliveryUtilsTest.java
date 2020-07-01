package com.google.play.core.godot.assetpacks.utils;

import static org.junit.Assert.*;

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

  @Test
  public void testAssetPackStateSerialization() {
    Dictionary testDictionary1 =
        constructAssetPackStateDictionaryHelper(42, 0, "awesomePack", 2, 65536, 35);
    AssetPackState testAssetPackState1 =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary1);
    Dictionary resultingDictionary1 =
        PlayAssetDeliveryUtils.convertAssetPackStateToDictionary(testAssetPackState1);
    assertThat(resultingDictionary1).isEqualTo(testDictionary1);

    Dictionary testDictionary2 =
        constructAssetPackStateDictionaryHelper(
            0, -6, "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", 7, 0, 0);
    AssetPackState testAssetPackState2 =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary2);
    Dictionary resultingDictionary2 =
        PlayAssetDeliveryUtils.convertAssetPackStateToDictionary(testAssetPackState2);
    assertThat(resultingDictionary2).isEqualTo(testDictionary2);
    assertThat(resultingDictionary2).isNotEqualTo(testDictionary1);

    // Test failure case where there is a missing key
    Dictionary testDictionary3 =
        constructAssetPackStateDictionaryHelper(42, 0, "awesomePack", 2, 65536, 35);
    testDictionary3.remove("bytesDownloaded");
    AssetPackState testAssetPackState3 =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(testDictionary3);
    Dictionary resultingDictionary3 =
        PlayAssetDeliveryUtils.convertAssetPackStateToDictionary(testAssetPackState3);
    assertThat(resultingDictionary3).isEqualTo(null);
  }
}

package com.google.play.core.godot.assetpacks.utils;

import static com.google.common.truth.Truth.assertThat;

import org.junit.Rule;
import org.junit.Test;

import org.godotengine.godot.Dictionary;

public class AssetPackStateFromDictionaryTest {

  @Test
  public void AssetPackStateFromDictionary_valid() {
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    AssetPackStateFromDictionary testSubject = new AssetPackStateFromDictionary(testDict);
    assertThat(testSubject.bytesDownloaded()).isEqualTo(42);
    assertThat(testSubject.errorCode()).isEqualTo(0);
    assertThat(testSubject.name()).isEqualTo("awesomePack");
    assertThat(testSubject.status()).isEqualTo(2);
    assertThat(testSubject.totalBytesToDownload()).isEqualTo(65536);
    assertThat(testSubject.transferProgressPercentage()).isEqualTo(35);
  }

  @Test(expected = NullPointerException.class)
  public void AssetPackStateFromDictionary_missingKey() {
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    testDict.remove("status");
    AssetPackStateFromDictionary testSubject = new AssetPackStateFromDictionary(testDict);
  }

  @Test(expected = ClassCastException.class)
  public void AssetPackStateFromDictionary_typeMismatch() {
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    testDict.put("status", "wrong type!");
    AssetPackStateFromDictionary testSubject = new AssetPackStateFromDictionary(testDict);
  }
}

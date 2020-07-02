/*
 	Copyright 2020 Google LLC

 	Licensed under the Apache License, Version 2.0 (the "License");
 	you may not use this file except in compliance with the License.
 	You may obtain a copy of the License at

 		https://www.apache.org/licenses/LICENSE-2.0

 	Unless required by applicable law or agreed to in writing, software
 	distributed under the License is distributed on an "AS IS" BASIS,
 	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 	See the License for the specific language governing permissions and
 	limitations under the License.
*/

package com.google.play.core.godot.assetpacks.utils;

import static com.google.common.truth.Truth.assertThat;

import org.godotengine.godot.Dictionary;
import org.junit.Test;

public class AssetPackStateFromDictionaryTest {

  @Test
  public void assetPackStateFromDictionary_valid() {
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

  @Test(expected = IllegalArgumentException.class)
  public void assetPackStateFromDictionary_missingKey() {
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    testDict.remove("status");
    AssetPackStateFromDictionary testSubject = new AssetPackStateFromDictionary(testDict);
  }

  @Test(expected = IllegalArgumentException.class)
  public void assetPackStateFromDictionary_typeMismatch() {
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    testDict.put("status", "wrong type!");
    AssetPackStateFromDictionary testSubject = new AssetPackStateFromDictionary(testDict);
  }
}

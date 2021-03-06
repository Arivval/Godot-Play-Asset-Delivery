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

import com.google.android.play.core.assetpacks.AssetPackState;
import com.google.play.core.godot.assetpacks.PlayAssetDeliveryTestHelper;
import org.godotengine.godot.Dictionary;
import org.junit.Test;

public class AssetPackStatesFromDictionaryTest {
  @Test
  public void assetPackStateFromDictionary_valid() {
    Dictionary testDict = PlayAssetDeliveryTestHelper.createAssetPackStatesTestDictionary();

    AssetPackStatesFromDictionary testSubject = new AssetPackStatesFromDictionary(testDict);
    assertThat(testSubject.totalBytes()).isEqualTo(65536);

    AssetPackState pack1 = testSubject.packStates().get("pack1");
    assertThat(pack1.bytesDownloaded()).isEqualTo(42);
    assertThat(pack1.errorCode()).isEqualTo(0);
    assertThat(pack1.name()).isEqualTo("awesomePack");
    assertThat(pack1.status()).isEqualTo(2);
    assertThat(pack1.totalBytesToDownload()).isEqualTo(65536);
    assertThat(pack1.transferProgressPercentage()).isEqualTo(35);

    AssetPackState pack2 = testSubject.packStates().get("pack2");
    assertThat(pack2.bytesDownloaded()).isEqualTo(0);
    assertThat(pack2.errorCode()).isEqualTo(-6);
    assertThat(pack2.name()).isEqualTo("Lorem ipsum dolor sit amet, consectetur adipiscing elit.");
    assertThat(pack2.status()).isEqualTo(7);
    assertThat(pack2.totalBytesToDownload()).isEqualTo(0);
    assertThat(pack2.transferProgressPercentage()).isEqualTo(0);
  }

  @Test(expected = IllegalArgumentException.class)
  public void assetPackStateFromDictionary_missingKey1() {
    Dictionary testDict = PlayAssetDeliveryTestHelper.createAssetPackStatesTestDictionary();
    testDict.remove(AssetPackStatesFromDictionary.TOTAL_BYTES_KEY);
    AssetPackStatesFromDictionary testSubject = new AssetPackStatesFromDictionary(testDict);
  }

  @Test(expected = IllegalArgumentException.class)
  public void assetPackStateFromDictionary_missingKey2() {
    Dictionary testDict = PlayAssetDeliveryTestHelper.createAssetPackStatesTestDictionary();
    Dictionary packStatesDict =
        (Dictionary) testDict.get(AssetPackStatesFromDictionary.PACK_STATES_KEY);
    Dictionary innerDict1 = (Dictionary) packStatesDict.get("pack1");
    innerDict1.remove(AssetPackStateFromDictionary.STATUS_KEY);
    AssetPackStatesFromDictionary testSubject = new AssetPackStatesFromDictionary(testDict);
  }

  @Test(expected = IllegalArgumentException.class)
  public void assetPackStateFromDictionary_typeMismatch1() {
    Dictionary testDict = PlayAssetDeliveryTestHelper.createAssetPackStatesTestDictionary();
    testDict.put(AssetPackStatesFromDictionary.TOTAL_BYTES_KEY, "wrong type");
    AssetPackStatesFromDictionary testSubject = new AssetPackStatesFromDictionary(testDict);
  }

  @Test(expected = IllegalArgumentException.class)
  public void assetPackStateFromDictionary_typeMismatch2() {
    Dictionary testDict = PlayAssetDeliveryTestHelper.createAssetPackStatesTestDictionary();
    Dictionary packStatesDict =
        (Dictionary) testDict.get(AssetPackStatesFromDictionary.PACK_STATES_KEY);
    Dictionary innerDict1 = (Dictionary) packStatesDict.get("pack1");
    innerDict1.put(AssetPackStateFromDictionary.STATUS_KEY, "wrong type");
    AssetPackStatesFromDictionary testSubject = new AssetPackStatesFromDictionary(testDict);
  }

  @Test(expected = IllegalArgumentException.class)
  public void assetPackStateFromDictionary_typeMismatch3() {
    Dictionary testDict = PlayAssetDeliveryTestHelper.createAssetPackStatesTestDictionary();
    Dictionary packStatesDict =
        (Dictionary) testDict.get(AssetPackStatesFromDictionary.PACK_STATES_KEY);
    packStatesDict.put("pack1", "wrong type");
    AssetPackStatesFromDictionary testSubject = new AssetPackStatesFromDictionary(testDict);
  }
}

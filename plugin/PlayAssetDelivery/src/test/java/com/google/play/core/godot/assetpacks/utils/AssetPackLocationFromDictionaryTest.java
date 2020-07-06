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

import org.godotengine.godot.Dictionary;
import org.junit.Test;

public class AssetPackLocationFromDictionaryTest {
  @Test
  public void assetPackLocationFromDictionary_valid() {
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Downloads/assetsPath", 0, "~/Downloads/extractedPath");
    AssetPackLocationFromDictionary testSubject = new AssetPackLocationFromDictionary(testDict);
    assertThat(testSubject.assetsPath()).isEqualTo("~/Downloads/assetsPath");
    assertThat(testSubject.packStorageMethod()).isEqualTo(0);
    assertThat(testSubject.path()).isEqualTo("~/Downloads/extractedPath");
  }

  @Test(expected = IllegalArgumentException.class)
  public void assetPackLocationFromDictionary_missingKey() {
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Downloads/assetsPath", 0, "~/Downloads/extractedPath");
    testDict.remove("path");
    AssetPackLocationFromDictionary testSubject = new AssetPackLocationFromDictionary(testDict);
  }

  @Test(expected = IllegalArgumentException.class)
  public void assetPackLocationFromDictionary_typeMismatch() {
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Downloads/assetsPath", 0, "~/Downloads/extractedPath");
    testDict.put("path", 123);
    AssetPackLocationFromDictionary testSubject = new AssetPackLocationFromDictionary(testDict);
  }
}

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

package com.google.play.core.godot.assetpacks.utils;

import org.godotengine.godot.Dictionary;
import org.junit.Test;

import static com.google.common.truth.Truth.assertThat;
import static org.junit.Assert.*;

public class AssetLocationFromDictionaryTest {
  @Test
  public void assetLocationFromDictionary_valid() {
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetLocationDictionary(42, "~/Downloads/dlc.pck", 65536);
    AssetLocationFromDictionary testSubject = new AssetLocationFromDictionary(testDict);
    assertThat(testSubject.offset()).isEqualTo(42);
    assertThat(testSubject.path()).isEqualTo("~/Downloads/dlc.pck");
    assertThat(testSubject.size()).isEqualTo(65536);
  }

  @Test(expected = IllegalArgumentException.class)
  public void assetLocationFromDictionary_missingKey() {
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetLocationDictionary(42, "~/Downloads/dlc.pck", 65536);
    testDict.remove("path");
    AssetPackStateFromDictionary testSubject = new AssetPackStateFromDictionary(testDict);
  }

  @Test(expected = IllegalArgumentException.class)
  public void assetLocationFromDictionary_typeMismatch() {
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetLocationDictionary(42, "~/Downloads/dlc.pck", 65536);
    testDict.put("offset", "wrong type!");
    AssetPackStateFromDictionary testSubject = new AssetPackStateFromDictionary(testDict);
  }
}

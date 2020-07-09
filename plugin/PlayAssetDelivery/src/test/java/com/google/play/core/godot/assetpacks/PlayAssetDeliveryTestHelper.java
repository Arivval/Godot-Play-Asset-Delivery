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

package com.google.play.core.godot.assetpacks;

import com.google.play.core.godot.assetpacks.utils.PlayAssetDeliveryUtils;
import org.godotengine.godot.Dictionary;

public class PlayAssetDeliveryTestHelper {
  public static Dictionary createAssetPackStatesTestDictionary() {
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
    return testDict;
  }

  public static Dictionary createAssetPackLocationsDictionary() {
    Dictionary innerDict1 =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Downloads/assetsPath", 0, "~/Downloads/extractedPath");
    Dictionary innerDict2 =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Downloads/assetsPath2", 0, "~/Downloads/extractedPath2");
    Dictionary testDict = new Dictionary();
    testDict.put("location1", innerDict1);
    testDict.put("location2", innerDict2);
    return testDict;
  }
}

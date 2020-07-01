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

import org.godotengine.godot.Dictionary;

import com.google.android.play.core.assetpacks.AssetPackState;
import com.google.android.play.core.assetpacks.AssetPackStates;
import com.google.android.play.core.assetpacks.AssetLocation;
import com.google.android.play.core.assetpacks.AssetPackLocation;

import java.util.Map;

public class PlayAssetDeliveryUtils {

  public static Dictionary convertAssetPackStateToDictionary(AssetPackState assetPackState) {
    Dictionary returnDict = new Dictionary();
    returnDict.put("bytesDownloaded", assetPackState.bytesDownloaded());
    returnDict.put("errorCode", assetPackState.errorCode());
    returnDict.put("name", assetPackState.name());
    returnDict.put("status", assetPackState.status());
    returnDict.put("totalBytesToDownload", assetPackState.totalBytesToDownload());
    returnDict.put("transferProgressPercentage", assetPackState.transferProgressPercentage());
    return returnDict;
  }

  public static Dictionary convertAssetPackStatesToDictionary(AssetPackStates assetPackStates) {
    Dictionary returnDict = new Dictionary();
    returnDict.put("totalBytes", assetPackStates.totalBytes());

    Map<String, AssetPackState> packStates = assetPackStates.packStates();
    Dictionary packStatesDictionary = new Dictionary();

    for (Map.Entry<String, AssetPackState> entry : packStates.entrySet()) {
      String packName = entry.getKey();
      AssetPackState packState = entry.getValue();
      packStatesDictionary.put(packName, packState);
    }

    returnDict.put("packStates", packStatesDictionary);
    return returnDict;
  }

  public static Dictionary convertAssetLocationToDictionary(AssetLocation assetLocation) {
    Dictionary returnDict = new Dictionary();
    returnDict.put("offset", assetLocation.offset());
    returnDict.put("path", assetLocation.path());
    returnDict.put("size", assetLocation.size());
    return returnDict;
  }

  public static Dictionary convertAssetPackLocationToDictionary(
      AssetPackLocation assetPackLocation) {
    Dictionary returnDict = new Dictionary();
    returnDict.put("assetsPath", assetPackLocation.assetsPath());
    returnDict.put("packStorageMethod", assetPackLocation.packStorageMethod());
    returnDict.put("path", assetPackLocation.packStorageMethod());
    return returnDict;
  }

  public static Dictionary convertAssetPackLocationsToDictionary(
      Map<String, AssetPackLocation> assetPackLocations) {
    Dictionary returnDict = new Dictionary();
    for (Map.Entry<String, AssetPackLocation> entry : assetPackLocations.entrySet()) {
      String packName = entry.getKey();
      AssetPackLocation packLocation = entry.getValue();
      returnDict.put(packName, packLocation);
    }
    return returnDict;
  }
}

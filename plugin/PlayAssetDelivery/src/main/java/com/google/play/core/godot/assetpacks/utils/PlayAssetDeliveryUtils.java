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

import com.google.android.play.core.assetpacks.AssetLocation;
import com.google.android.play.core.assetpacks.AssetPackState;
import org.godotengine.godot.Dictionary;

/**
 * This class contains all the helper methods for serializing/deserializing custom objects used in
 * the Play Asset Delivery API. The Java objects are serialized into
 * org.godotengine.godot.Dictionary, which the Godot runtime can receive.
 */
public class PlayAssetDeliveryUtils {

  private static final String TAG = "PlayAssetDeliveryUtils";

  public static Dictionary constructAssetPackStateDictionary(
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

  public static Dictionary constructAssetLocationDictionary(long offset, String path, long size) {
    Dictionary returnDict = new Dictionary();
    returnDict.put("offset", offset);
    returnDict.put("path", path);
    returnDict.put("size", size);
    return returnDict;
  }

  public static Dictionary convertAssetPackStateToDictionary(AssetPackState assetPackState) {
    return constructAssetPackStateDictionary(
        assetPackState.bytesDownloaded(),
        assetPackState.errorCode(),
        assetPackState.name(),
        assetPackState.status(),
        assetPackState.totalBytesToDownload(),
        assetPackState.transferProgressPercentage());
  }

  public static Dictionary convertAssetLocationToDictionary(AssetLocation assetLocation) {
    return constructAssetLocationDictionary(
        assetLocation.offset(), assetLocation.path(), assetLocation.size());
  }

  public static AssetPackState convertDictionaryToAssetPackState(Dictionary dict)
      throws IllegalArgumentException {
    return new AssetPackStateFromDictionary(dict);
  }

  public static AssetLocation convertDictionaryToAssetLocation(Dictionary dict)
      throws IllegalArgumentException {
    return new AssetLocationFromDictionary(dict);
  }
}

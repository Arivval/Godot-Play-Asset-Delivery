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

import android.util.Log;

import org.godotengine.godot.Dictionary;

import com.google.android.play.core.assetpacks.AssetPackState;

/**
 * This class contains all the helper methods for serializing/deserializing custom objects used in
 * the Play Asset Delivery API. The Java objects are serialized into
 * org.godotengine.godot.Dictionary, which the Godot runtime can receive. For all helper functions,
 * null is return upon exception.
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

  public static Dictionary convertAssetPackStateToDictionary(AssetPackState assetPackState) {
    try {
      return constructAssetPackStateDictionary(
          assetPackState.bytesDownloaded(),
          assetPackState.errorCode(),
          assetPackState.name(),
          assetPackState.status(),
          assetPackState.totalBytesToDownload(),
          assetPackState.transferProgressPercentage());
    } catch (Exception e) {
      Log.w(TAG, "Exception while converting AssetPackState object to Dictionary!", e);
      return null;
    }
  }

  public static AssetPackState convertDictionaryToAssetPackState(final Dictionary dict) {
    try {
      AssetPackState packState =
          new AssetPackState() {
            @Override
            public String name() {
              return (String) dict.get("name");
            }

            @Override
            public int status() {
              return (int) dict.get("status");
            }

            @Override
            public int errorCode() {
              return (int) dict.get("errorCode");
            }

            @Override
            public long bytesDownloaded() {
              return (long) dict.get("bytesDownloaded");
            }

            @Override
            public long totalBytesToDownload() {
              return (long) dict.get("totalBytesToDownload");
            }

            @Override
            public int transferProgressPercentage() {
              return (int) dict.get("transferProgressPercentage");
            }
          };
      return packState;
    } catch (Exception e) {
      Log.w(TAG, "Exception while converting Dictionary to AssetPackState object!", e);
      return null;
    }
  }
}

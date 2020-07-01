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

  public static Dictionary convertAssetPackStateToDictionary(AssetPackState assetPackState) {
    try {
      Dictionary returnDict = new Dictionary();
      returnDict.put("bytesDownloaded", assetPackState.bytesDownloaded());
      returnDict.put("errorCode", assetPackState.errorCode());
      returnDict.put("name", assetPackState.name());
      returnDict.put("status", assetPackState.status());
      returnDict.put("totalBytesToDownload", assetPackState.totalBytesToDownload());
      returnDict.put("transferProgressPercentage", assetPackState.transferProgressPercentage());
      return returnDict;
    } catch (Exception e) {
      Log.w(TAG, "Exception while converting AssetPackState object to Dictionary!", e);
      return null;
    }
  }

  public static AssetPackState convertDictionaryToAssetPackState(Dictionary dict) {
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

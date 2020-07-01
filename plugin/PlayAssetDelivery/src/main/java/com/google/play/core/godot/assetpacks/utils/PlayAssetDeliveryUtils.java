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
import com.google.android.play.core.assetpacks.AssetPackStates;
import com.google.android.play.core.assetpacks.AssetLocation;
import com.google.android.play.core.assetpacks.AssetPackLocation;

import java.util.HashMap;
import java.util.Map;

/**
 * This class contains all the helper methods for serialize/deserialize custom objects used in the
 * Play Asset Delivery API. The Java objects are serialized into org.godotengine.godot.Dictionary,
 * which the Godot runtime can receive. For all helper functions, null is return upon exception.
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

  public static Dictionary convertAssetPackStatesToDictionary(AssetPackStates assetPackStates) {
    try {
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
    } catch (Exception e) {
      Log.w(TAG, "Exception while converting AssetPackStates object to Dictionary!", e);
      return null;
    }
  }

  public static Dictionary convertAssetLocationToDictionary(AssetLocation assetLocation) {
    try {
      Dictionary returnDict = new Dictionary();
      returnDict.put("offset", assetLocation.offset());
      returnDict.put("path", assetLocation.path());
      returnDict.put("size", assetLocation.size());
      return returnDict;
    } catch (Exception e) {
      Log.w(TAG, "Exception while converting AssetLocation object to Dictionary!", e);
      return null;
    }
  }

  public static Dictionary convertAssetPackLocationToDictionary(
      AssetPackLocation assetPackLocation) {
    try {
      Dictionary returnDict = new Dictionary();
      returnDict.put("assetsPath", assetPackLocation.assetsPath());
      returnDict.put("packStorageMethod", assetPackLocation.packStorageMethod());
      returnDict.put("path", assetPackLocation.packStorageMethod());
      return returnDict;
    } catch (Exception e) {
      Log.w(TAG, "Exception while converting AssetPackLocation object to Dictionary!", e);
      return null;
    }
  }

  public static Dictionary convertAssetPackLocationsToDictionary(
      Map<String, AssetPackLocation> assetPackLocations) {
    try {
      Dictionary returnDict = new Dictionary();
      for (Map.Entry<String, AssetPackLocation> entry : assetPackLocations.entrySet()) {
        String packName = entry.getKey();
        AssetPackLocation packLocation = entry.getValue();
        returnDict.put(packName, packLocation);
      }
      return returnDict;
    } catch (Exception e) {
      Log.w(TAG, "Exception while converting AssetPackLocations to Dictionary!", e);
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

  public static AssetPackStates convertDictionaryToAssetPackStates(final Dictionary dict) {
    try {
      AssetPackStates assetPackStates =
          new AssetPackStates() {
            @Override
            public long totalBytes() {
              return (long) dict.get("totalBytes");
            }

            @Override
            public Map<String, AssetPackState> packStates() {
              Map<String, AssetPackState> returnMap = new HashMap<String, AssetPackState>();
              for (Map.Entry<String, Object> entry : dict.entrySet()) {
                AssetPackState currentPackState =
                    convertDictionaryToAssetPackState((Dictionary) entry.getValue());
                returnMap.put(entry.getKey(), currentPackState);
              }
              return returnMap;
            }
          };
      return assetPackStates;
    } catch (Exception e) {
      Log.w(TAG, "Exception while converting Dictionary to AssetPackStates object!", e);
      return null;
    }
  }

  public static AssetLocation convertDictionaryToAssetLocation(final Dictionary dict) {
    try {
      AssetLocation assetLocation =
          new AssetLocation() {
            @Override
            public String path() {
              return (String) dict.get("path");
            }

            @Override
            public long offset() {
              return (long) dict.get("offset");
            }

            @Override
            public long size() {
              return (long) dict.get("size");
            }
          };
      return assetLocation;
    } catch (Exception e) {
      Log.w(TAG, "Exception while converting Dictionary to AssetLocation object!", e);
      return null;
    }
  }

  public static AssetPackLocation convertDictionaryToAssetPackLocation(final Dictionary dict) {
    try {
      AssetPackLocation assetPackLocation =
          new AssetPackLocation() {
            @Override
            public int packStorageMethod() {
              return (int) dict.get("packStorageMethod");
            }

            @Override
            public String path() {
              return (String) dict.get("path");
            }

            @Override
            public String assetsPath() {
              return (String) dict.get("assetsPath");
            }
          };
      return assetPackLocation;
    } catch (Exception e) {
      Log.w(TAG, "Exception while converting Dictionary to AssetPackLocation object!", e);
      return null;
    }
  }

  public static Map<String, AssetPackLocation> convertDictionaryToAssetPackLocations(
      final Dictionary dict) {
    try {
      Map<String, AssetPackLocation> returnMap = new HashMap<String, AssetPackLocation>();
      for (Map.Entry<String, Object> entry : dict.entrySet()) {
        AssetPackLocation currentPackLocation =
            convertDictionaryToAssetPackLocation((Dictionary) entry.getValue());
        returnMap.put(entry.getKey(), currentPackLocation);
      }
      return returnMap;
    } catch (Exception e) {
      Log.w(TAG, "Exception while converting Dictionary to AssetPackLocations!", e);
      return null;
    }
  }
}

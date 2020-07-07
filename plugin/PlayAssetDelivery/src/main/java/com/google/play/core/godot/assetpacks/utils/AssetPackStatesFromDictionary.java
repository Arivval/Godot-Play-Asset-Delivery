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

import com.google.android.play.core.assetpacks.AssetPackState;
import com.google.android.play.core.assetpacks.AssetPackStates;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import org.godotengine.godot.Dictionary;

/**
 * This class extends the AssetPackStates abstract class, and provides constructor that allows
 * PlayAssetDeliveryUtils class to instantiate AssetPackStatesFromDictionary given a Godot
 * Dictionary.
 */
public class AssetPackStatesFromDictionary extends AssetPackStates {
  private long totalBytes;
  private Map<String, AssetPackState> packStates;

  public static final String TOTAL_BYTES_KEY = "totalBytes";
  public static final String PACK_STATES_KEY = "packStates";

  private static final Set<String> dictionaryRequiredKeySet =
      new HashSet<>(Arrays.asList(TOTAL_BYTES_KEY, PACK_STATES_KEY));

  public AssetPackStatesFromDictionary(Dictionary dict) throws IllegalArgumentException {
    if (dict.keySet().containsAll(dictionaryRequiredKeySet)) {
      try {
        this.totalBytes = (long) dict.get(TOTAL_BYTES_KEY);
        Dictionary packStatesDictionary = (Dictionary) dict.get(PACK_STATES_KEY);
        Map<String, AssetPackState> returnMap = new HashMap<String, AssetPackState>();
        for (Map.Entry<String, Object> entry : packStatesDictionary.entrySet()) {
          AssetPackStateFromDictionary currentPackState =
              new AssetPackStateFromDictionary((Dictionary) entry.getValue());
          returnMap.put(entry.getKey(), currentPackState);
        }
        this.packStates = returnMap;
      } catch (ClassCastException e) {
        throw new IllegalArgumentException("Invalid input Dictionary, value type mismatch!");
      }
    } else {
      throw new IllegalArgumentException(
          "Invalid input Dictionary, does not contain all required keys!");
    }
  }

  @Override
  public long totalBytes() {
    return this.totalBytes;
  }

  @Override
  public Map<String, AssetPackState> packStates() {
    return this.packStates;
  }
}

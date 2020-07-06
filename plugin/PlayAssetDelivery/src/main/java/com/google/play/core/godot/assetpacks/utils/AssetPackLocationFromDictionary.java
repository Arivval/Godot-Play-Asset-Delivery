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

import com.google.android.play.core.assetpacks.AssetPackLocation;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import org.godotengine.godot.Dictionary;

/**
 * This class extends the AssetPackLocation abstract class, and provides constructor that allows
 * PlayAssetDeliveryUtils class to instantiate AssetPackLocation given a Godot Dictionary.
 */
public class AssetPackLocationFromDictionary extends AssetPackLocation {
  private String assetsPath;
  private int packStorageMethod;
  private String path;

  public static final String ASSETS_PATH_KEY = "assetsPath";
  public static final String PACK_STORAGE_METHOD_KEY = "packStorageMethod";
  public static final String PATH_KEY = "path";

  private static final Set<String> dictionaryRequiredKeySet =
      new HashSet<>(Arrays.asList(ASSETS_PATH_KEY, PACK_STORAGE_METHOD_KEY, PATH_KEY));

  public AssetPackLocationFromDictionary(Dictionary dict) throws IllegalArgumentException {
    if (dict.keySet().containsAll(dictionaryRequiredKeySet)) {
      try {
        this.assetsPath = (String) dict.get(ASSETS_PATH_KEY);
        this.packStorageMethod = (int) dict.get(PACK_STORAGE_METHOD_KEY);
        this.path = (String) dict.get(PATH_KEY);
      } catch (ClassCastException e) {
        throw new IllegalArgumentException("Invalid input Dictionary, value type mismatch!");
      }
    } else {
      throw new IllegalArgumentException(
          "Invalid input Dictionary, does not contain all required keys!");
    }
  }

  @Override
  public String assetsPath() {
    return null;
  }

  @Override
  public int packStorageMethod() {
    return this.packStorageMethod;
  }

  @Override
  public String path() {
    return this.path;
  }
}

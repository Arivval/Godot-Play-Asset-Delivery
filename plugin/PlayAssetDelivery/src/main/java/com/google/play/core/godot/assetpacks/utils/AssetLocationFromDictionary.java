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

import com.google.android.play.core.assetpacks.AssetLocation;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import org.godotengine.godot.Dictionary;

/**
 * This class extends the AssetLocation abstract class, and provides constructor that allows
 * PlayAssetDeliveryUtils class to instantiate AssetLocation given a Godot Dictionary.
 */
public class AssetLocationFromDictionary extends AssetLocation {
  private long offset;
  private String path;
  private long size;

  public static final String OFFSET_KEY = "offset";
  public static final String PATH_KEY = "path";
  public static final String SIZE_KEY = "size";

  private static final Set<String> dictionaryRequiredKeySet =
      new HashSet<>(Arrays.asList(OFFSET_KEY, PATH_KEY, SIZE_KEY));

  public AssetLocationFromDictionary(Dictionary dict) throws IllegalArgumentException {
    if (dict.keySet().containsAll(dictionaryRequiredKeySet)) {
      try {
        this.offset = (long) dict.get(OFFSET_KEY);
        this.path = (String) dict.get(PATH_KEY);
        this.size = (long) dict.get(SIZE_KEY);
      } catch (ClassCastException e) {
        throw new IllegalArgumentException("Invalid input Dictionary, value type mismatch!");
      }
    } else {
      throw new IllegalArgumentException(
          "Invalid input Dictionary, does not contain all required keys!");
    }
  }

  @Override
  public long offset() {
    return this.offset;
  }

  @Override
  public String path() {
    return this.path;
  }

  @Override
  public long size() {
    return this.size;
  }
}

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

import com.google.android.play.core.assetpacks.AssetPackState;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import org.godotengine.godot.Dictionary;

/**
 * This class extends the AssetPackState abstract class, and provides constructor that allows
 * PlayAssetDeliveryUtils class to instantiate AssetPackStateFromDictionary given a Godot
 * Dictionary.
 */
public class AssetPackStateFromDictionary extends AssetPackState {
  private String name;
  private int status;
  private int errorCode;
  private long bytesDownloaded;
  private long totalBytesToDownload;
  private int transferProgressPercentage;

  public static final String key1 = "name";
  public static final String key2 = "status";
  public static final String key3 = "errorCode";
  public static final String key4 = "bytesDownloaded";
  public static final String key5 = "totalBytesToDownload";
  public static final String key6 = "transferProgressPercentage";

  private static final Set<String> dictionaryRequiredKeySet =
      new HashSet<>(Arrays.asList(key1, key2, key3, key4, key5, key6));

  public AssetPackStateFromDictionary(Dictionary dict) throws IllegalArgumentException {
    if (dict.keySet().containsAll(dictionaryRequiredKeySet)) {
      try {
        this.name = (String) dict.get(key1);
        this.status = (int) dict.get(key2);
        this.errorCode = (int) dict.get(key3);
        this.bytesDownloaded = (long) dict.get(key4);
        this.totalBytesToDownload = (long) dict.get(key5);
        this.transferProgressPercentage = (int) dict.get(key6);
      } catch (ClassCastException e) {
        throw new IllegalArgumentException("Invalid input Dictionary, value type mismatch!");
      } catch (Exception e) {
        throw e;
      }
    } else {
      throw new IllegalArgumentException(
          "Invalid input Dictionary, does not contain all required keys!");
    }
  }

  @Override
  public String name() {
    return this.name;
  }

  @Override
  public int status() {
    return this.status;
  }

  @Override
  public int errorCode() {
    return this.errorCode;
  }

  @Override
  public long bytesDownloaded() {
    return this.bytesDownloaded;
  }

  @Override
  public long totalBytesToDownload() {
    return this.totalBytesToDownload;
  }

  @Override
  public int transferProgressPercentage() {
    return this.transferProgressPercentage;
  }
}

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

import java.util.HashSet;
import java.util.Set;
import java.util.Arrays;

/**
 * This class extends the AssetPackState abstract class, and provides constructor that allows
 * PlayAssetDeliveryUtils class to instantiate AssetPackStateFromDictionary given Godot Dictionary.
 */
public class AssetPackStateFromDictionary extends AssetPackState {
  private String name;
  private int status;
  private int errorCode;
  private long bytesDownloaded;
  private long totalBytesToDownload;
  private int transferProgressPercentage;

  public AssetPackStateFromDictionary(Dictionary dict)
      throws NullPointerException, ClassCastException {
    Set<String> dictionaryRequiredKeySet =
        new HashSet<>(
            Arrays.asList(
                "name",
                "status",
                "errorCode",
                "bytesDownloaded",
                "totalBytesToDownload",
                "transferProgressPercentage"));
    if (dict.keySet().containsAll(dictionaryRequiredKeySet)) {
      this.name = (String) dict.get("name");
      this.status = (int) dict.get("status");
      this.errorCode = (int) dict.get("errorCode");
      this.bytesDownloaded = (long) dict.get("bytesDownloaded");
      this.totalBytesToDownload = (long) dict.get("totalBytesToDownload");
      this.transferProgressPercentage = (int) dict.get("transferProgressPercentage");
    } else {
      throw new NullPointerException("Invalid input Dictionary!");
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

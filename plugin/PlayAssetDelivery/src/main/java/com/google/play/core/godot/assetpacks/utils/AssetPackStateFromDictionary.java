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

  public static final String NAME_KEY = "name";
  public static final String STATUS_KEY = "status";
  public static final String ERROR_CODE_KEY = "errorCode";
  public static final String BYTES_DOWNLOADED_KEY = "bytesDownloaded";
  public static final String TOTAL_BYTES_TO_DOWNLOAD_KEY = "totalBytesToDownload";
  public static final String TRANSFER_PROGRESS_PERCENTAGE_KEY = "transferProgressPercentage";

  private static final Set<String> dictionaryRequiredKeySet =
      new HashSet<>(
          Arrays.asList(
              NAME_KEY,
              STATUS_KEY,
              ERROR_CODE_KEY,
              BYTES_DOWNLOADED_KEY,
              TOTAL_BYTES_TO_DOWNLOAD_KEY,
              TRANSFER_PROGRESS_PERCENTAGE_KEY));

  public AssetPackStateFromDictionary(Dictionary dict) throws IllegalArgumentException {
    if (dict.keySet().containsAll(dictionaryRequiredKeySet)) {
      try {
        this.name = (String) dict.get(NAME_KEY);
        this.status = (int) dict.get(STATUS_KEY);
        this.errorCode = (int) dict.get(ERROR_CODE_KEY);
        this.bytesDownloaded = (long) dict.get(BYTES_DOWNLOADED_KEY);
        this.totalBytesToDownload = (long) dict.get(TOTAL_BYTES_TO_DOWNLOAD_KEY);
        this.transferProgressPercentage = (int) dict.get(TRANSFER_PROGRESS_PERCENTAGE_KEY);
      } catch (ClassCastException e) {
        throw new IllegalArgumentException("Invalid input Dictionary, value type mismatch!");
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

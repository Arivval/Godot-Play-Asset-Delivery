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
import com.google.android.play.core.assetpacks.AssetPackException;
import com.google.android.play.core.assetpacks.AssetPackLocation;
import com.google.android.play.core.assetpacks.AssetPackState;
import com.google.android.play.core.assetpacks.AssetPackStates;
import com.google.android.play.core.assetpacks.model.AssetPackErrorCode;
import java.util.Map;
import java.util.stream.Collectors;
import org.godotengine.godot.Dictionary;

/**
 * This class contains all the helper methods for serializing/deserializing custom objects used in
 * the Play Asset Delivery API. The Java objects are serialized into
 * org.godotengine.godot.Dictionary, which the Godot runtime can receive.
 */
public class PlayAssetDeliveryUtils {

  public static final String ASSETPACK_EXCEPTION_DICTIONARY_TYPE_KEY = "type";
  public static final String ASSETPACK_EXCEPTION_DICTIONARY_MESSAGE_KEY = "message";
  public static final String ASSETPACK_EXCEPTION_DICTIONARY_ERROR_CODE_KEY = "errorCode";

  public static Dictionary constructAssetPackStateDictionary(
      long bytesDownloaded,
      int errorCode,
      String name,
      int status,
      long totalBytesToDownload,
      int transferProgressPercentage) {
    Dictionary returnDict = new Dictionary();
    returnDict.put(AssetPackStateFromDictionary.NAME_KEY, name);
    returnDict.put(AssetPackStateFromDictionary.STATUS_KEY, status);
    returnDict.put(AssetPackStateFromDictionary.ERROR_CODE_KEY, errorCode);
    returnDict.put(AssetPackStateFromDictionary.BYTES_DOWNLOADED_KEY, bytesDownloaded);
    returnDict.put(AssetPackStateFromDictionary.TOTAL_BYTES_TO_DOWNLOAD_KEY, totalBytesToDownload);
    returnDict.put(
        AssetPackStateFromDictionary.TRANSFER_PROGRESS_PERCENTAGE_KEY, transferProgressPercentage);
    return returnDict;
  }

  public static Dictionary constructAssetPackStatesDictionary(
      long totalBytes, Dictionary packStatesDictionary) {
    Dictionary returnDict = new Dictionary();
    returnDict.put(AssetPackStatesFromDictionary.TOTAL_BYTES_KEY, totalBytes);
    returnDict.put(AssetPackStatesFromDictionary.PACK_STATES_KEY, packStatesDictionary);
    return returnDict;
  }

  public static void appendToAssetPackStatesDictionary(
      Dictionary assetPackStatesDict, String packName, Dictionary packStateDict) {
    Dictionary packStatesDict =
        (Dictionary) assetPackStatesDict.get(AssetPackStatesFromDictionary.PACK_STATES_KEY);
    packStatesDict.put(packName, packStateDict);
  }

  public static Dictionary constructAssetLocationDictionary(long offset, String path, long size) {
    Dictionary returnDict = new Dictionary();
    returnDict.put(AssetLocationFromDictionary.OFFSET_KEY, offset);
    returnDict.put(AssetLocationFromDictionary.PATH_KEY, path);
    returnDict.put(AssetLocationFromDictionary.SIZE_KEY, size);
    return returnDict;
  }

  public static Dictionary constructAssetPackLocationDictionary(
      String assetsPath, int packStorageMethod, String path) {
    Dictionary returnDict = new Dictionary();
    returnDict.put(AssetPackLocationFromDictionary.ASSETS_PATH_KEY, assetsPath);
    returnDict.put(AssetPackLocationFromDictionary.PACK_STORAGE_METHOD_KEY, packStorageMethod);
    returnDict.put(AssetPackLocationFromDictionary.PATH_KEY, path);
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

  public static Dictionary convertAssetPackStatesToDictionary(AssetPackStates assetPackStates) {
    Dictionary packStatesDictionary =
        assetPackStates
            .packStates()
            .entrySet()
            .stream()
            .collect(
                Dictionary::new,
                (d, e) -> d.put(e.getKey(), convertAssetPackStateToDictionary(e.getValue())),
                (d1, d2) -> d1.putAll(d2));
    Dictionary returnDict =
        constructAssetPackStatesDictionary(assetPackStates.totalBytes(), packStatesDictionary);
    return returnDict;
  }

  public static Dictionary convertAssetLocationToDictionary(AssetLocation assetLocation) {
    return constructAssetLocationDictionary(
        assetLocation.offset(), assetLocation.path(), assetLocation.size());
  }

  public static Dictionary convertAssetPackLocationToDictionary(
      AssetPackLocation assetPackLocation) {
    return constructAssetPackLocationDictionary(
        assetPackLocation.assetsPath(),
        assetPackLocation.packStorageMethod(),
        assetPackLocation.path());
  }

  public static Dictionary convertAssetPackLocationsToDictionary(
      Map<String, AssetPackLocation> assetPackLocations) {
    return assetPackLocations
        .entrySet()
        .stream()
        .collect(
            Dictionary::new,
            (d, e) -> d.put(e.getKey(), convertAssetPackLocationToDictionary(e.getValue())),
            (d1, d2) -> d1.putAll(d2));
  }

  /**
   * Serializes an Exception object into Godot Dictionary. If the Exception is not an
   * AssetPackException, the errorCode entry in returnDict will be set to
   * AssetPackErrorCode.INTERNAL_ERROR.
   *
   * @param e Exception to be converted to Dictionary
   * @return serialized Dictionary
   */
  public static Dictionary convertExceptionToDictionary(final Exception e) {
    Dictionary returnDict = new Dictionary();
    returnDict.put(ASSETPACK_EXCEPTION_DICTIONARY_TYPE_KEY, e.getClass().getCanonicalName());
    returnDict.put(ASSETPACK_EXCEPTION_DICTIONARY_MESSAGE_KEY, e.getMessage());

    if (e instanceof AssetPackException) {
      returnDict.put(
          ASSETPACK_EXCEPTION_DICTIONARY_ERROR_CODE_KEY, ((AssetPackException) e).getErrorCode());
    } else {
      returnDict.put(
          ASSETPACK_EXCEPTION_DICTIONARY_ERROR_CODE_KEY, AssetPackErrorCode.INTERNAL_ERROR);
    }

    return returnDict;
  }

  public static AssetPackState convertDictionaryToAssetPackState(Dictionary dict)
      throws IllegalArgumentException {
    return new AssetPackStateFromDictionary(dict);
  }

  public static AssetPackStates convertDictionaryToAssetPackStates(Dictionary dict)
      throws IllegalArgumentException {
    return new AssetPackStatesFromDictionary(dict);
  }

  public static AssetLocation convertDictionaryToAssetLocation(Dictionary dict)
      throws IllegalArgumentException {
    return new AssetLocationFromDictionary(dict);
  }

  public static AssetPackLocation convertDictionaryToAssetPackLocation(Dictionary dict)
      throws IllegalArgumentException {
    return new AssetPackLocationFromDictionary(dict);
  }

  public static Map<String, AssetPackLocation> convertDictionaryToAssetPackLocations(
      Dictionary dict) throws IllegalArgumentException {
    try {
      return dict.entrySet()
          .stream()
          .collect(
              Collectors.toMap(
                  e -> e.getKey(),
                  e -> convertDictionaryToAssetPackLocation((Dictionary) e.getValue())));
    } catch (ClassCastException e) {
      throw new IllegalArgumentException(
          "Invalid input Dictionary, unable to cast entry to Dictionary");
    }
  }
}

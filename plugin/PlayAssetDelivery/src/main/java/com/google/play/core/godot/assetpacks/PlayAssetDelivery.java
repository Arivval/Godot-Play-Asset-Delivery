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

package com.google.play.core.godot.assetpacks;

import android.content.Context;
import androidx.annotation.NonNull;
import com.google.android.play.core.assetpacks.AssetLocation;
import com.google.android.play.core.assetpacks.AssetPackLocation;
import com.google.android.play.core.assetpacks.AssetPackManager;
import com.google.android.play.core.assetpacks.AssetPackManagerFactory;
import com.google.android.play.core.assetpacks.AssetPackStates;
import com.google.android.play.core.tasks.OnFailureListener;
import com.google.android.play.core.tasks.OnSuccessListener;
import com.google.android.play.core.tasks.Task;
import com.google.play.core.godot.assetpacks.utils.PlayAssetDeliveryUtils;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.godotengine.godot.Dictionary;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;

/**
 * This class is served as a middleware, to expose the Play Core Java library to the Godot runtime,
 * so Godot Play Asset Delivery front-end API is able to access the related Java APIs. This class is
 * intended to be compiled to an .AAR Android Library, which can be loaded into Godot Engine as a
 * Godot Android Plugin.
 */
public class PlayAssetDelivery extends GodotPlugin {

  private AssetPackManager assetPackManager;

  private final String ASSET_PACK_STATE_UPDATED = "assetPackStateUpdated";
  private final String FETCH_STATE_UPDATED = "fetchStateUpdated";
  private final String FETCH_SUCCESS = "fetchSuccess";
  private final String FETCH_ERROR = "fetchError";
  private final String GET_PACK_STATES_SUCCESS = "getPackStatesSuccess";
  private final String GET_PACK_STATES_ERROR = "getPackStatesError";
  private final String REMOVE_PACK_SUCCESS = "removePackSuccess";
  private final String REMOVE_PACK_ERROR = "removePackError";
  private final String SHOW_CELLULAR_DATA_CONFIRMATION_SUCCESS =
      "showCellularDataConfirmationSuccess";
  private final String SHOW_CELLULAR_DATA_CONFIRMATION_ERROR = "showCellularDataConfirmationError";

  public PlayAssetDelivery(Godot godot) {
    super(godot);
    Context applicationContext = godot.getApplicationContext();
    assetPackManager = AssetPackManagerFactory.getInstance(applicationContext);
  }

  /** Package-private constructor used to instantiate PlayAssetDelivery class with mock objects. */
  PlayAssetDelivery(Godot godot, AssetPackManager assetPackManager) {
    super(godot);
    this.assetPackManager = assetPackManager;
  }

  /**
   * Package-private wrapper function used for argument captor (since emitSignal() is protected).
   */
  void emitSignalWrapper(String signalName, Object... signalArgs) {
    emitSignal(signalName, signalArgs);
  }

  @NonNull
  @Override
  public String getPluginName() {
    return "PlayAssetDelivery";
  }

  /** Returns a list of all plugin method names that the Godot runtime can call. */
  @NonNull
  @Override
  public List<String> getPluginMethods() {
    return Arrays.asList(
        "cancel",
        "fetch",
        "getAssetLocation",
        "getPackLocation",
        "getPackLocations",
        "getPackStates",
        "removePack",
        "showCellularDataConfirmation");
  }

  /**
   * Returns a set containing all the signals the Godot runtime is able to receive.
   * Below is the documentation for all signals registered.
   * <pre>
   * AssetPackStateUpdateSignal - passes AssetPackState serialized as Dictionary.
   * All the signals below also passes signalID. fetchSuccess - passes
   * AssetPackStates serialized as Dictionary.
   * fetchError - passes Error serialized as Dictionary.
   * getPackStatesSuccess - passes AssetPackStates serialized as Dictionary.
   * getPackStatesError - passes Error serialized as Dictionary.
   * removePackSuccess - passes name of the pack removed.
   * removePackError - passes name of the pack to be removed along with the Error serialized as
   * Dictionary.
   * showCellularDataConfirmationSuccess - passes Integer indicating how the user
   * responded to the dialog.
   * showCellularDataConfirmationError - passes Error serialized as Dictionary.
   * <pre/>
   */
  @NonNull
  @Override
  public Set<SignalInfo> getPluginSignals() {
    Set<SignalInfo> availableSignals = new HashSet<>();
    availableSignals.add(new SignalInfo(ASSET_PACK_STATE_UPDATED, Dictionary.class));
    availableSignals.add(new SignalInfo(FETCH_STATE_UPDATED, Dictionary.class, Integer.class));
    availableSignals.add(new SignalInfo(FETCH_SUCCESS, Dictionary.class, Integer.class));
    availableSignals.add(new SignalInfo(FETCH_ERROR, Dictionary.class, Integer.class));
    availableSignals.add(new SignalInfo(GET_PACK_STATES_SUCCESS, Dictionary.class, Integer.class));
    availableSignals.add(new SignalInfo(GET_PACK_STATES_ERROR, Dictionary.class, Integer.class));
    availableSignals.add(new SignalInfo(REMOVE_PACK_SUCCESS, Integer.class));
    availableSignals.add(new SignalInfo(REMOVE_PACK_ERROR, Dictionary.class, Integer.class));
    availableSignals.add(
        new SignalInfo(SHOW_CELLULAR_DATA_CONFIRMATION_SUCCESS, Integer.class, Integer.class));
    availableSignals.add(
        new SignalInfo(SHOW_CELLULAR_DATA_CONFIRMATION_ERROR, Dictionary.class, Integer.class));
    return availableSignals;
  }

  /**
   * Calls cancel(List<String> packNames) method in the Play Core Library. Requests to cancel the
   * download of the specified asset packs.
   *
   * @return serialized AssetPackStates object
   */
  public Dictionary cancel(String[] packNames) {
    AssetPackStates updatedStates = assetPackManager.cancel(Arrays.asList(packNames));
    return PlayAssetDeliveryUtils.convertAssetPackStatesToDictionary(updatedStates);
  }

  /**
   * Calls getAssetLocation(String packName, String assetPath) method in the Play Core Library.
   * Returns the location of an asset in a pack, or null if the asset is not present in the given
   * pack.
   *
   * @return serialized AssetLocation object
   */
  public Dictionary getAssetLocation(String packName, String assetPath) {
    AssetLocation retrievedAssetLocation = assetPackManager.getAssetLocation(packName, assetPath);
    if (retrievedAssetLocation == null) {
      return null;
    }
    return PlayAssetDeliveryUtils.convertAssetLocationToDictionary(retrievedAssetLocation);
  }

  /**
   * Calls getPackLocation(String packName) method in the Play Core Library. Returns the location of
   * the specified asset pack on the device or null if this pack is not downloaded or is outdated.
   *
   * @return serialized AssetPackLocation object
   */
  public Dictionary getPackLocation(String packName) {
    AssetPackLocation retrievedPackLocation = assetPackManager.getPackLocation(packName);
    if (retrievedPackLocation == null) {
      return null;
    }
    return PlayAssetDeliveryUtils.convertAssetPackLocationToDictionary(retrievedPackLocation);
  }

  /**
   * Calls getPackLocations() method in the Play Core Library. Returns the location of all installed
   * asset packs as a mapping from the asset pack name to an AssetPackLocation.
   *
   * @return serialized abstract Map<String, AssetPackLocation> object
   */
  public Dictionary getPackLocations() {
    Map<String, AssetPackLocation> packLocationsMap = assetPackManager.getPackLocations();
    return PlayAssetDeliveryUtils.convertAssetPackLocationsToDictionary(packLocationsMap);
  }

  /**
   * Calls getPackStates(List<String> packNames) method in the Play Core Library. Requests download
   * state or details for the specified asset packs. Emits getPackStatesSuccess and
   * getPackStatesError signals when the underlying task succeeds/fails.
   *
   * @param packNames list of name for all the packs to request states
   * @param signalID identifier used to track mapping of signals to Tasks
   */
  public void getPackStates(List<String> packNames, int signalID) {
    OnSuccessListener<AssetPackStates> getPackStatesSuccessListener =
        result ->
            emitSignalWrapper(
                GET_PACK_STATES_SUCCESS,
                PlayAssetDeliveryUtils.convertAssetPackStatesToDictionary(result),
                signalID);
    OnFailureListener getPackStatesFailureListener =
        e ->
            emitSignalWrapper(
                GET_PACK_STATES_ERROR,
                PlayAssetDeliveryUtils.convertExceptionToDictionary(e),
                signalID);

    Task<AssetPackStates> getPackStatesTask = assetPackManager.getPackStates(packNames);
    getPackStatesTask.addOnSuccessListener(getPackStatesSuccessListener);
    getPackStatesTask.addOnFailureListener(getPackStatesFailureListener);
  }

  /**
   * Calls removePack(String packName, int signalID) method in the Play Core Library. Deletes the
   * specified asset pack from the internal storage of the app. Emits removePackSuccess and
   * removePackError signals when the underlying task succeeds/fails.
   *
   * @param packName name of the asset pack to be removed
   * @param signalID identifier used to track mapping of signals to Tasks
   */
  public void removePack(String packName, int signalID) {
    OnSuccessListener<Void> removePackOnSuccessListener =
        result -> emitSignalWrapper(REMOVE_PACK_SUCCESS, signalID);
    OnFailureListener removePackOnFailureListener =
        e ->
            emitSignalWrapper(
                REMOVE_PACK_ERROR,
                PlayAssetDeliveryUtils.convertExceptionToDictionary(e),
                signalID);

    Task<Void> removePackTask = assetPackManager.removePack(packName);
    removePackTask.addOnSuccessListener(removePackOnSuccessListener);
    removePackTask.addOnFailureListener(removePackOnFailureListener);
  }

  /**
   * Directly calls showCellularDataConfirmation(Activity activity). The current activity can be
   * accessed using (Context) getGodot().getApplicationContext(); Shows a confirmation dialog to
   * resume all pack downloads that are currently in the WAITING_FOR_WIFI state. Emits
   * showCellularDataConfirmationSuccess and showCellularDataConfirmationError signals when the
   * underlying task succeeds/fails.
   *
   * @param signalID identifier used to track mapping of signals to Tasks
   */
  public void showCellularDataConfirmation(int signalID) {
    OnSuccessListener<Integer> showCellularDataConfirmationSuccessListener =
        result -> emitSignalWrapper(SHOW_CELLULAR_DATA_CONFIRMATION_SUCCESS, result, signalID);
    OnFailureListener showCellularDataConfirmationFailureListener =
        e ->
            emitSignalWrapper(
                SHOW_CELLULAR_DATA_CONFIRMATION_ERROR,
                PlayAssetDeliveryUtils.convertExceptionToDictionary(e),
                signalID);

    Task<Integer> showCellularDataConfirmationTask =
        assetPackManager.showCellularDataConfirmation(getGodot());
    showCellularDataConfirmationTask.addOnSuccessListener(
        showCellularDataConfirmationSuccessListener);
    showCellularDataConfirmationTask.addOnFailureListener(
        showCellularDataConfirmationFailureListener);
  }
}

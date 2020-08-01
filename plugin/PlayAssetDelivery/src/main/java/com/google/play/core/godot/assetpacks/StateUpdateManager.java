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

/**
 * This class keep track of all the ongoing asset pack requests and most updated asset pack states.
 * Provides forceAssetPackStateUpdate() function to force-emit stateUpdated global signals, so that
 * we are able to get the most updated asset pack state when the app is resumed from background.
 */
package com.google.play.core.godot.assetpacks;

import static com.google.play.core.godot.assetpacks.PlayAssetDelivery.ASSET_PACK_STATE_UPDATED;

import com.google.android.play.core.assetpacks.AssetPackManager;
import com.google.android.play.core.assetpacks.AssetPackState;
import com.google.android.play.core.assetpacks.model.AssetPackStatus;
import com.google.play.core.godot.assetpacks.utils.PlayAssetDeliveryUtils;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import org.godotengine.godot.Dictionary;

public class StateUpdateManager {
  private Set<String> ongoingAssetPackRequests;
  private Map<String, Dictionary> updatedAssetPackStateMap;
  private final List<Integer> assetPackTerminalStates =
      Arrays.asList(AssetPackStatus.COMPLETED, AssetPackStatus.FAILED, AssetPackStatus.CANCELED);
  PlayAssetDelivery playAssetDeliveryPlugin;
  private AssetPackManager assetPackManager;

  Set<String> ongoingAssetPackRequests() {
    return ongoingAssetPackRequests;
  }

  Map<String, Dictionary> updatedAssetPackStateMap() {
    return updatedAssetPackStateMap;
  }

  public void joinOngoingAssetPackRequests(Set<String> newOngoingAssetPackRequests) {
    ongoingAssetPackRequests.addAll(newOngoingAssetPackRequests);
  }

  public StateUpdateManager(
      PlayAssetDelivery playAssetDeliveryPlugin, AssetPackManager assetPackManager) {
    this.playAssetDeliveryPlugin = playAssetDeliveryPlugin;
    this.assetPackManager = assetPackManager;
    ongoingAssetPackRequests = Collections.synchronizedSet(new HashSet<>());
    updatedAssetPackStateMap = new ConcurrentHashMap();
  }

  /** Package-private wrapper function used for argument captor. */
  void emitSignalWrapper(String signalName, Object... signalArgs) {
    playAssetDeliveryPlugin.emitSignalWrapper(signalName, signalArgs);
  }
  /**
   * Function that emits assetPackStateUpdated signal if the given assetPackState has been updated.
   */
  public void emitNonDuplicateStateUpdatedSignal(
      AssetPackState assetPackState, boolean addToOngoingAssetPackRequests) {
    boolean isDifferentState;
    Dictionary assetPackStateDictionary;
    synchronized (this) {
      boolean isTerminalState = assetPackTerminalStates.contains(assetPackState.status());
      if (isTerminalState) {
        ongoingAssetPackRequests.remove(assetPackState);
      }
      if (!isTerminalState && addToOngoingAssetPackRequests) {
        ongoingAssetPackRequests.add(assetPackState.name());
      }
      assetPackStateDictionary =
          PlayAssetDeliveryUtils.convertAssetPackStateToDictionary(assetPackState);
      isDifferentState =
          !updatedAssetPackStateMap.containsKey(assetPackState.name())
              || updatedAssetPackStateMap.get(assetPackState.name()).hashCode()
                  != assetPackStateDictionary.hashCode();
      if (isDifferentState) {
        updatedAssetPackStateMap.put(assetPackState.name(), assetPackStateDictionary);
      }
    }
    // emit signal outside the synchronized block
    if (isDifferentState) {
      emitSignalWrapper(ASSET_PACK_STATE_UPDATED, assetPackStateDictionary);
    }
  }

  /**
   * Calls getPackStates on all asset packs currently in non-terminal state and emit non-duplicating
   * stateUpdated signals.
   */
  public void forceAssetPackStateUpdate() {
    assetPackManager
        .getPackStates(new ArrayList<>(ongoingAssetPackRequests))
        .addOnSuccessListener(
            result ->
                result
                    .packStates()
                    .values()
                    .stream()
                    .forEach(
                        updatedState -> emitNonDuplicateStateUpdatedSignal(updatedState, false)));
  }
}

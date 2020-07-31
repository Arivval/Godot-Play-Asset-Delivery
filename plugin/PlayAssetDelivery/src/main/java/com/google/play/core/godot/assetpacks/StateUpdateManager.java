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

  public Set<String> ongoingAssetPackRequests() {
    return ongoingAssetPackRequests;
  }

  public Map<String, Dictionary> updatedAssetPackStateMap() {
    return updatedAssetPackStateMap;
  }

  public StateUpdateManager(
      PlayAssetDelivery playAssetDeliveryPlugin, AssetPackManager assetPackManager) {
    this.playAssetDeliveryPlugin = playAssetDeliveryPlugin;
    this.assetPackManager = assetPackManager;
    ongoingAssetPackRequests = Collections.synchronizedSet(new HashSet<>());
    updatedAssetPackStateMap = new ConcurrentHashMap();
  }

  /**
   * Function that emits assetPackStateUpdated signal if the given assetPackState has been updated.
   */
  public synchronized void emitNonDuplicateStateUpdatedSignal(
      AssetPackState assetPackState, boolean addToOngoingAssetPackRequests) {
    boolean isTerminalState = assetPackTerminalStates.contains(assetPackState.status());
    if (isTerminalState) {
      ongoingAssetPackRequests.remove(assetPackState);
    }
    if (!isTerminalState && addToOngoingAssetPackRequests) {
      ongoingAssetPackRequests.add(assetPackState.name());
    }
    Dictionary assetPackStateDictionary =
        PlayAssetDeliveryUtils.convertAssetPackStateToDictionary(assetPackState);
    boolean isDifferentState =
        !(updatedAssetPackStateMap.containsKey(assetPackState.name())
            && updatedAssetPackStateMap.get(assetPackState.name()).hashCode()
                == assetPackStateDictionary.hashCode());
    if (isDifferentState) {
      updatedAssetPackStateMap.put(assetPackState.name(), assetPackStateDictionary);
      playAssetDeliveryPlugin.emitSignalWrapper(ASSET_PACK_STATE_UPDATED, assetPackStateDictionary);
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

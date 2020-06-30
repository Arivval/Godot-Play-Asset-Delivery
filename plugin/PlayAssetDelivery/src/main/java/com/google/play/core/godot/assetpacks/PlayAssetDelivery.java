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

package com.google.play.core.godot.assetpacks;

import androidx.annotation.NonNull;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;

import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.HashSet;

public class PlayAssetDelivery extends GodotPlugin {

    public PlayAssetDelivery(Godot godot) {
        super(godot);
    }

    @NonNull
    @Override
    public String getPluginName() {
        return "PlayAssetDelivery";
    }

    @NonNull
    @Override
    public List<String> getPluginMethods() {
        return Arrays.asList("cancel", "fetch", "getAssetLocation", "getPackLocation",
                "getPackLocations", "getPackStates", "removePack", "showCellularDataConfirmation");
    }

    @NonNull
    @Override
    public Set<SignalInfo> getPluginSignals() {
        Set<SignalInfo> availableSignals = new HashSet<>();
        availableSignals.add(new SignalInfo("assetPackStateUpdateSignal",
                String.class));
        availableSignals.add(new SignalInfo("fetchStateUpdated", String.class,
                Integer.class));
        availableSignals.add(new SignalInfo("fetchSuccess", String.class,
                Integer.class));
        availableSignals.add(new SignalInfo("fetchError", String.class, Integer.class));
        availableSignals.add(new SignalInfo("getPackStatesSuccess", String.class,
                Integer.class));
        availableSignals.add(new SignalInfo("getPackStatesError", String.class,
                Integer.class));
        availableSignals.add(new SignalInfo("removePackSuccess", String.class,
                Integer.class));
        availableSignals.add(new SignalInfo("removePackError", String.class,
                String.class, Integer.class));
        availableSignals.add(new SignalInfo("showCellularDataConfirmationSuccess",
                Integer.class, Integer.class));
        availableSignals.add(new SignalInfo("showCellularDataConfirmationError",
                String.class, Integer.class));
        return availableSignals;
    }
}

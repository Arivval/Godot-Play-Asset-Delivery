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

import static org.mockito.Matchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.google.android.play.core.assetpacks.AssetPackException;
import com.google.android.play.core.assetpacks.AssetPackState;
import com.google.android.play.core.tasks.OnFailureListener;
import com.google.android.play.core.tasks.OnSuccessListener;
import com.google.android.play.core.tasks.Task;
import com.google.play.core.godot.assetpacks.utils.PlayAssetDeliveryUtils;
import java.util.ArrayList;
import java.util.List;
import org.godotengine.godot.Dictionary;

public class PlayAssetDeliveryTestHelper {
  public static Dictionary createAssetPackStatesTestDictionary() {
    Dictionary innerDict1 =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            42, 0, "awesomePack", 2, 65536, 35);
    Dictionary innerDict2 =
        PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
            0, -6, "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", 7, 0, 0);
    Dictionary testDict =
        PlayAssetDeliveryUtils.constructAssetPackStatesDictionary(65536, new Dictionary());
    PlayAssetDeliveryUtils.appendToAssetPackStatesDictionary(testDict, "pack1", innerDict1);
    PlayAssetDeliveryUtils.appendToAssetPackStatesDictionary(testDict, "pack2", innerDict2);
    return testDict;
  }

  public static Dictionary createAssetPackLocationsDictionary() {
    Dictionary innerDict1 =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Downloads/assetsPath", 0, "~/Downloads/extractedPath");
    Dictionary innerDict2 =
        PlayAssetDeliveryUtils.constructAssetPackLocationDictionary(
            "~/Downloads/assetsPath2", 0, "~/Downloads/extractedPath2");
    Dictionary testDict = new Dictionary();
    testDict.put("location1", innerDict1);
    testDict.put("location2", innerDict2);
    return testDict;
  }

  public static List<AssetPackState> createAssetPackStateList() {
    List<AssetPackState> returnList = new ArrayList<>();

    AssetPackState packState1 =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(
            PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
                42, 0, "awesomePack", 2, 65536, 35));
    AssetPackState packState2 =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(
            PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
                256, 0, "awesomePack", 2, 65536, 35));
    AssetPackState packState3 =
        PlayAssetDeliveryUtils.convertDictionaryToAssetPackState(
            PlayAssetDeliveryUtils.constructAssetPackStateDictionary(
                4096, 0, "awesomePack", 2, 65536, 35));

    returnList.add(packState1);
    returnList.add(packState2);
    returnList.add(packState3);

    return returnList;
  }

  /**
   * Mock object factory that returns a mock Task<T> object. Will invoke onSuccessListener with
   * result if addOnSuccessListener() is called.
   *
   * @param result object to be passed to the onSuccessListener
   * @param <T> parameterized type of the result returned by this task if it succeeds
   * @return instantiated mock Task
   */
  public static <T> Task<T> createMockOnSuccessTask(T result) {
    Task<T> returnTaskMock = mock(Task.class);
    doAnswer(
            invocation -> {
              OnSuccessListener<T> listener = (OnSuccessListener<T>) invocation.getArguments()[0];
              listener.onSuccess(result);
              return null;
            })
        .when(returnTaskMock)
        .addOnSuccessListener(any(OnSuccessListener.class));
    return returnTaskMock;
  }

  /**
   * Mock object factory that returns a mock Task<T> object. Will invoke onFailureListener with
   * onFailureException if addOnFailureListener() is called.
   *
   * @param onFailureException Exception to be passed to the onFailureListener
   * @param <T> parameterized type of the result returned by this task if it succeeds
   * @return instantiated mock Task
   */
  public static <T> Task<T> createMockOnFailureTask(Exception onFailureException) {
    Task<T> returnTaskMock = mock(Task.class);
    doAnswer(
            invocation -> {
              OnFailureListener listener = (OnFailureListener) invocation.getArguments()[0];
              listener.onFailure(onFailureException);
              return null;
            })
        .when(returnTaskMock)
        .addOnFailureListener(any(OnFailureListener.class));
    return returnTaskMock;
  }

  /** Returns a mock AssetPackException object used for unit testing. */
  public static AssetPackException createMockAssetPackException() {
    AssetPackException testException = mock(AssetPackException.class);
    when(testException.toString())
        .thenReturn("java.lang.RuntimeException.AssetPackException: testException!");
    when(testException.getErrorCode()).thenReturn(-7);
    return testException;
  }
}

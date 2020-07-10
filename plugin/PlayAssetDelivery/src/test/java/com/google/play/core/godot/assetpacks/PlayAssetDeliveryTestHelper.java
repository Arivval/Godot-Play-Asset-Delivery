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

import static com.google.common.truth.Truth.assertThat;
import static org.mockito.Matchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.google.android.play.core.assetpacks.AssetPackException;
import com.google.android.play.core.tasks.OnFailureListener;
import com.google.android.play.core.tasks.OnSuccessListener;
import com.google.android.play.core.tasks.Task;
import com.google.play.core.godot.assetpacks.utils.PlayAssetDeliveryUtils;
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

  /**
   * When calling getClass() method on mocked objects, the returned named will contain Mockito
   * specific suffix such as
   * com.google.android.play.core.assetpacks.AssetPackException$$EnhancerByMockitoWithCGLIB$$c5.
   * Hence we need this helper function to apply string operations to only take the prefix.
   *
   * @param mockitoClassName raw string with Mockito given suffix
   * @return string representing the actual class name
   */
  private static String convertMockitoClassNameToActualClassName(String mockitoClassName) {
    int dollarSignIndex = mockitoClassName.indexOf("$$");
    assertThat(dollarSignIndex).isNotEqualTo(-1);
    return mockitoClassName.substring(0, dollarSignIndex);
  }

  public static void assertMockAssetPackExceptionDictionaryIsExpected(
      Dictionary mockExceptionDictionary, String expectedMessage, int expectedErrorCode) {
    String testExceptionType =
        (String) mockExceptionDictionary.get(PlayAssetDeliveryUtils.ASSETPACK_DICTIONARY_TYPE_KEY);

    testExceptionType = convertMockitoClassNameToActualClassName(testExceptionType);

    assertThat(testExceptionType).isEqualTo(AssetPackException.class.getCanonicalName());
    assertThat(mockExceptionDictionary.get(PlayAssetDeliveryUtils.ASSETPACK_DICTIONARY_MESSAGE_KEY))
        .isEqualTo(expectedMessage);
    assertThat(
            mockExceptionDictionary.get(PlayAssetDeliveryUtils.ASSETPACK_DICTIONARY_ERROR_CODE_KEY))
        .isEqualTo(expectedErrorCode);
    assertThat(mockExceptionDictionary.entrySet().size()).isEqualTo(3);
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

  /**
   * Returns a mock AssetPackException object used for unit testing.
   *
   * @param message String to be returned upon getMessage()
   * @param errorCode int to be returned upon getErrorCode()
   * @return instantiated mock AssetPackException object
   */
  public static AssetPackException createMockAssetPackException(String message, int errorCode) {
    AssetPackException testException = mock(AssetPackException.class);
    when(testException.getMessage()).thenReturn(message);
    when(testException.getErrorCode()).thenReturn(errorCode);
    return testException;
  }
}

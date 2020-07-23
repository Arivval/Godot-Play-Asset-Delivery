# ##############################################################################
#
#	Copyright 2020 Google LLC
#
#	Licensed under the Apache License, Version 2.0 (the "License");
#	you may not use this file except in compliance with the License.
#	You may obtain a copy of the License at
#
#		https://www.apache.org/licenses/LICENSE-2.0
#
#	Unless required by applicable law or agreed to in writing, software
#	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.
#
# ##############################################################################
#
# Object used to define the expected behavior of assetPackStateUpdated signal in 
# FakeAndroidPlugin. The result field will be an AssetPackState Dictionary.
#
# ##############################################################################
class_name FakeAssetPackStateUpdatedInfo
extends Object

var thread : Thread
var result : Dictionary

func _init(result : Dictionary):
	self.result = result

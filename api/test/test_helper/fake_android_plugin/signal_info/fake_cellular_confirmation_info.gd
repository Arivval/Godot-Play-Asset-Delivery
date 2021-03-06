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
# Object used to define the expected behavior of calling 
# showCellularDataConfirmation() in FakeAndroidPlugin. The result field will be 
# a CellularDataConfirmationResult enum.
#
# ##############################################################################
class_name FakeCellularConfirmationInfo
extends Object

var thread : Thread
var success : bool
var result : int
var error : Dictionary

func _init(success : bool, result : int, error : Dictionary):
	self.success = success
	self.result = result
	self.error = error

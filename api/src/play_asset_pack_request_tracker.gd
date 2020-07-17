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
# The PlayAssetPackRequestTracker class generates unique signal_id integers and
# keeps a mapping of signal_id to Request objects. This signal_id is used as an
# identifier and passed to the Android plugin, so that we can know which signal
# emitted from the plugin corresponds to which Request object
#
# ##############################################################################
class_name PlayAssetPackRequestTracker
extends Object

var signal_id_counter : int

func _init():
	signal_id_counter = 0

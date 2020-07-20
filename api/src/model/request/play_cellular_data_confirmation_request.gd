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
# TODO
#
# ##############################################################################
class_name PlayCellularDataConfirmationRequest
extends PlayAssetDeliveryRequest

func on_show_cellular_data_confirmation_success(result : int):
	emit_signal("request_completed", true, result)

func on_show_cellular_data_confirmation_error(error: Dictionary):
	emit_signal("request_completed", true, error)



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
# Object used to capture data emitted by a stream of signals. Stream of 
# arguments collected in received_params_store.
#
# ##############################################################################
class_name SignalCaptor
extends Object

# 2d list storing each argument emitted by each signal
var received_params_store = []
var _arg_count : int

func _init(arg_count : int):
	_arg_count = arg_count

func signal_call_back(arg1, arg2 = null, arg3 = null, arg4 = null):
	# Arguments are defaulted to null since this function can accept 1 to 4 arguments.
	# varargs feature is not supported in GDScript, so this is as close as we can get.
	var args = [arg1, arg2, arg3, arg4]
	received_params_store.append(args.slice(0, _arg_count - 1))
		
	

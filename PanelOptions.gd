extends Panel


#func _ready():
	## Connect the focus exited signal to the hide function
	##focus_exited.connect(hide_panel)
	#
	## Make sure the Panel can receive focus
	##focus_mode = Control.FOCUS_ALL
	#
	#grab_focus()
#
#func _on_focus_exited():
	## Set process_input to false when focus is lost
	#set_process_input(false)
#
#func _input(event):
	#if event is InputEventKey and event.pressed:
		#match event.keycode:
			#KEY_ESCAPE:
				#function_1()
				#get_viewport().set_input_as_handled()
#
#func function_1():
	#print("Function 1 called (ESC)")
	#get_node("/root/Noter")._hide_options()

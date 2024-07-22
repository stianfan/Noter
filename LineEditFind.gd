extends LineEdit

func _ready():
	# Connect the focus entered and exited signals
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	set_process_input(false)

func _on_focus_entered():
	# Set process_input to true when focus is gained
	set_process_input(true)

func _on_focus_exited():
	# Set process_input to false when focus is lost
	set_process_input(false)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				function_1()
				get_viewport().set_input_as_handled()
			KEY_TAB :
				get_viewport().set_input_as_handled()
				if not event.shift_pressed:
					function_2()
				else:
					function_3()
			KEY_F3 :
				if not event.shift_pressed:
					function_2()
				else:
					function_3()
				get_viewport().set_input_as_handled()
			KEY_UP:
				function_3()
				get_viewport().set_input_as_handled()
			KEY_DOWN:
				function_2()
				get_viewport().set_input_as_handled()

func function_1():
	print("Function 1 called (ESC)")
	get_node("/root/Noter")._find_hide()

func function_2():
	print("Function 2 called (TAB or UP)")
	get_node("/root/Noter")._on_find_next()
	grab_focus()

func function_3():
	print("Function 3 called (Shift+TAB or DOWN)")
	get_node("/root/Noter")._on_find_previous()
	grab_focus()

extends Button

var dragging = false
var drag_start_pos = Vector2i.ZERO
var initial_window_size = Vector2i.ZERO

func _ready():
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_button_down():
	dragging = true
	drag_start_pos = Vector2i(get_global_mouse_position())
	initial_window_size = get_window().size

func _on_button_up():
	dragging = false

func _process(delta):
	if dragging:
		var current_mouse_pos = Vector2i(get_global_mouse_position())
		var drag_distance = current_mouse_pos - drag_start_pos
		
		var new_size = initial_window_size + drag_distance
		new_size = new_size.clamp(Vector2i(420, 420), Vector2i(4000, 4000))
		
		get_window().size = new_size

func _on_mouse_entered():
	mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE

func _on_mouse_exited():
	mouse_default_cursor_shape = Control.CURSOR_ARROW

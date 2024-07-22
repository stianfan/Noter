extends Control

var colorFG: Color = Color(1, 1, 1, 1)
var colorBG: Color = Color(0.109804, 0.109804, 0.109804, 1)
var color2: Color = Color(1, 0, 0, 1)
var font_path: String = ''
var font_s: int = 13

const CONFIG_FILE_PATH = "user://settings.cfg"

@onready var color_picker_fg: ColorPickerButton = $PanelOptions/VBoxContainer3/VBoxContainer/HBoxContainer2/ColorPickerButtonFG
@onready var color_picker_bg: ColorPickerButton = $PanelOptions/VBoxContainer3/VBoxContainer/HBoxContainer/ColorPickerButtonBG
@onready var color_picker_2: ColorPickerButton = $PanelOptions/VBoxContainer3/VBoxContainer/HBoxContainer3/ColorPickerButton2
@onready var timer = $Timer
@onready var text_edit = $MainWindow/MarginContainer/TextEdit
@onready var find_line_edit = $PanelFindUi/HBoxContainer/LineEditFind
@onready var find_next_button = $PanelFindUi/HBoxContainer/VBoxContainer/ButtonFindNext
@onready var find_prev_button = $PanelFindUi/HBoxContainer/VBoxContainer/ButtonFindPrev
@onready var match_label = $MainWindow/HBoxContainer/LabelStatus
@onready var check_button = $PanelOptions/VBoxContainer3/VBoxContainer2/CheckButton
@onready var file_dialog = $FileDialogFont
@onready var spin_box = $PanelOptions/VBoxContainer3/VBoxContainer2/HBoxContainer/SpinBox
@onready var option_button = $PanelOptions/VBoxContainer3/VBoxContainer/OptionButton
@onready var panel_options = $PanelOptions
@onready var button_pin = $MainWindow/HBoxContainer/ButtonPin
@onready var hbox_container = $MainWindow/HBoxContainer

var app_name = "noter"
var current_file = ""
var following = false
var dragging_start_position = Vector2()
var tween: Tween
var current_find_index = -1
var find_results = []

func _ready():
	move_pin_button_if_macos()
	load_settings()
	update_window_title()
	set_global_colors(colorFG, colorBG, color2)
	
	change_panel_color()
	_check_status()
	
	$MainWindow/HBoxContainer/MenuButton.get_popup().id_pressed.connect(self._on_item_pressed)
	get_tree().root.files_dropped.connect(_on_files_dropped)
	var args = OS.get_cmdline_args()
	if args.size() > 0:
		var path = args[0]
		if FileAccess.file_exists(path):
			load_file(path)
		else:
			set_temporary_text("Not found", 3.0, 0.5)
	
	find_line_edit.text_changed.connect(_on_find_text_changed)
	find_next_button.pressed.connect(_on_find_next)
	find_prev_button.pressed.connect(_on_find_previous)
	_toggle_find_ui(false)
	
	color_picker_fg.color_changed.connect(on_fg_color_changed)
	color_picker_bg.color_changed.connect(on_bg_color_changed)
	color_picker_2.color_changed.connect(on_2_color_changed)
	get_tree().root.size_changed.connect(save_settings)
	
	file_dialog.file_selected.connect(on_font_selected)
	
	text_edit.add_theme_color_override("search_result_color", Color(colorFG.r, colorFG.g, colorFG.b, 0.2))  
	text_edit.add_theme_color_override("search_result_border_color", Color(color2.r, color2.g, color2.b, 0.5))  
	text_edit.add_theme_color_override("selection_color", color2) 
	text_edit.add_theme_color_override("font_selected_color", colorFG)
	text_edit.add_theme_color_override("word_highlighted_color", Color(colorFG.r, colorFG.g, colorFG.b, 0.2))
	
	spin_box.value = font_s
	spin_box.value_changed.connect(_on_spin_box_value_changed)
	
	setup_custom_colors()
	apply_font_size()
	modify_context_menu()
		
	option_button.item_selected.connect(_on_option_button_item_selected)
		
func setup_custom_colors():
	$MainWindow/HBoxContainer/ButtonPin.add_theme_color_override("font_color", Color(color2))
	$MainWindow/HBoxContainer/ButtonPin.add_theme_color_override("font_focus_color", Color(color2))
	$MainWindow/HBoxContainer/ButtonPin.add_theme_color_override("font_pressed_color", Color(colorBG))
	
	$MainWindow/HBoxContainer/MenuButton.add_theme_color_override("font_color", Color(color2))
	$MainWindow/HBoxContainer/MenuButton.add_theme_color_override("font_pressed_color", Color(colorFG))
	$MainWindow/HBoxContainer/MenuButton.add_theme_color_override("font_focus_color", Color(color2))
	
	$MainWindow/HBoxContainer/ButtonMin.add_theme_color_override("font_color", Color(color2))
	$MainWindow/HBoxContainer/ButtonMin.add_theme_color_override("font_pressed_color", Color(colorBG))
	$MainWindow/HBoxContainer/ButtonMin.add_theme_color_override("font_focus_color", Color(color2))
	
	$MainWindow/HBoxContainer/ButtonQuit.add_theme_color_override("font_color", Color(color2))
	$MainWindow/HBoxContainer/ButtonQuit.add_theme_color_override("font_pressed_color", Color(colorBG))
	$MainWindow/HBoxContainer/ButtonQuit.add_theme_color_override("font_focus_color", Color(color2))
	
	$PanelFindUi/HBoxContainer/VBoxContainer/ButtonFindNext.add_theme_color_override("font_color", Color(color2))
	$PanelFindUi/HBoxContainer/VBoxContainer/ButtonFindNext.add_theme_color_override("font_pressed_color", Color(colorBG))
	$PanelFindUi/HBoxContainer/VBoxContainer/ButtonFindNext.add_theme_color_override("font_focus_color", Color(color2))
	
	
	$PanelFindUi/HBoxContainer/VBoxContainer/ButtonFindPrev.add_theme_color_override("font_color", Color(color2))
	$PanelFindUi/HBoxContainer/VBoxContainer/ButtonFindPrev.add_theme_color_override("font_pressed_color", Color(colorBG))
	$PanelFindUi/HBoxContainer/VBoxContainer/ButtonFindPrev.add_theme_color_override("font_focus_color", Color(color2))
	
	
	
	$MainWindow/MarginContainer/TextEdit.add_theme_font_size_override("font_size", 13)
	
	check_button.add_theme_color_override("font_color", Color(colorFG))
	check_button.add_theme_color_override("font_focus_color", Color(colorFG))
	check_button.add_theme_color_override("font_pressed_color", Color(color2))
	check_button.add_theme_color_override("font_hover_color", Color(color2))
	check_button.add_theme_color_override("font_hover_pressed_color", Color(color2))
	
	

func _on_find_shortcut_triggered():
	_toggle_find_ui(true)
	find_line_edit.grab_focus()

func _find_hide():
	_toggle_find_ui(false)
	$PanelFindUi/HBoxContainer/LineEditFind.text = ''

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F and event.ctrl_pressed:
			_toggle_find_ui(visible)
			find_line_edit.grab_focus()
			get_viewport().set_input_as_handled()
		elif event.pressed and event.keycode == KEY_N and event.ctrl_pressed:
			new_file()
		elif event.pressed and event.keycode == KEY_O and event.ctrl_pressed:
			$FileDialogOpen.popup()
		elif event.pressed and event.keycode == KEY_S and event.ctrl_pressed:
			save_file()
		elif event.pressed and event.keycode == KEY_S and event.ctrl_pressed and event.shift_pressed:
			$FileDialogSave.popup()
		elif event.pressed and event.keycode == KEY_Q and event.ctrl_pressed:
			get_tree().quit()
		elif event.pressed and event.keycode == KEY_PERIOD and event.ctrl_pressed:
			$PanelOptions.visible = visible
			set_colors_options(0)
			setup_option_button()
			update_color_pickers()
			

func _toggle_find_ui(visible):
	$PanelFindUi.visible = visible
	match_label.modulate.a = 1
	if not visible:
		_clear_search()
		match_label.text = ""
		match_label.modulate.a = 0

func _on_find_text_changed(new_text):
	_clear_search()
	if new_text.is_empty():
		return
	
	text_edit.set_search_text(new_text)
	find_results = _search_text(new_text)
	current_find_index = -1
	_update_match_label()
	if not find_results.is_empty():
		_on_find_next()
	_toggle_find_ui(true)

func _search_text(search_text: String) -> Array:
	var results = []
	var line_count = text_edit.get_line_count()
	for i in range(line_count):
		var line_text = text_edit.get_line(i)
		var column = 0
		while true:
			column = line_text.find(search_text, column)
			if column == -1:
				break
			results.append(Vector2i(column, i))
			column += search_text.length()
	return results

func _highlight_current_result():
	text_edit.deselect()
	if current_find_index >= 0 and current_find_index < find_results.size():
		var result = find_results[current_find_index]
		var search_text = find_line_edit.text
		text_edit.select(result.y, result.x, result.y, result.x + search_text.length())
		text_edit.set_caret_line(result.y)
		text_edit.set_caret_column(result.x + search_text.length())
		text_edit.center_viewport_to_caret()
	_update_match_label()

func _clear_search():
	text_edit.set_search_text("")
	text_edit.deselect()
	find_results.clear()
	current_find_index = -1
	match_label.text = ""

func _on_find_next():
	if find_results.is_empty():
		return
	current_find_index = (current_find_index + 1) % find_results.size()
	_highlight_current_result()

func _on_find_previous():
	if find_results.is_empty():
		return
	current_find_index = (current_find_index - 1 + find_results.size()) % find_results.size()
	_highlight_current_result()

func _update_match_label():
	if find_results.is_empty():
		match_label.text = "No matches"
	else:
		match_label.text = "Match %d of %d" % [current_find_index + 1, find_results.size()]
	match_label.visible = true

func _on_files_dropped(files):
	if files.size() > 0:
		var path = files[0]
		load_file(path)

func _on_item_pressed(id: int):
	match id:
		0:
			new_file()
		1:
			$FileDialogOpen.popup()
		2:
			save_file()
		3:
			$FileDialogSave.popup()
		4:
			_toggle_find_ui(visible)
			find_line_edit.grab_focus()
			get_viewport().set_input_as_handled()
			pass
		5:
			pass
		6:
			$PanelOptions.visible = visible
			set_colors_options(0)
			setup_option_button()
			update_color_pickers()
			
		7:
			save_settings()
			get_tree().quit()

func save_file():
	var path = current_file
	if path == '':
		$FileDialogSave.popup()
	
		var f2 = FileAccess.open(path, FileAccess.WRITE)
		f2.store_string($MainWindow/MarginContainer/TextEdit.text)
		update_window_title()
		set_temporary_text("File saved", 3.0, 0.5)
		f2.close
	else:
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string($MainWindow/MarginContainer/TextEdit.text)
		set_temporary_text("File saved", 3.0, 0.5)
		file.close()

func set_text_after_last_slash(current_file: String):
	var last_slash_index = max(current_file.rfind("/"), current_file.rfind("\\"))
	if last_slash_index != -1:
		$MainWindow/HBoxContainer/VBoxContainer/LabelTitle.text = current_file.substr(last_slash_index + 1)
		$MainWindow/HBoxContainer/VBoxContainer/LabelPath.text = current_file.substr(0, last_slash_index)
	else:
		$MainWindow/HBoxContainer/VBoxContainer/LabelTitle.text = current_file
		$MainWindow/HBoxContainer/VBoxContainer/LabelPath.text = ""

func update_window_title():
	DisplayServer.window_set_title(app_name + ' - ' + current_file)
	set_text_after_last_slash(current_file)

func new_file():
	current_file = ''
	$MainWindow/MarginContainer/TextEdit.text = ''
	set_temporary_text("New file", 3.0, 0.5)
	update_window_title()

func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and following:
		DisplayServer.window_set_position(DisplayServer.window_get_position() + Vector2i(get_global_mouse_position() - dragging_start_position))
	

func _on_button_quit_pressed():
	get_tree().quit()


func _on_file_dialog_open_file_selected(path):
	var f = FileAccess.open(path, FileAccess.READ)
	f.open(path, 1)
	$MainWindow/MarginContainer/TextEdit.text = f.get_as_text()
	current_file = path
	update_window_title()
	set_temporary_text("File loaded", 3.0, 0.5)
	f.close


func _on_file_dialog_save_file_selected(path):
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.open(path, 2)
	f.store_string($MainWindow/MarginContainer/TextEdit.text)
	current_file = path
	update_window_title()
	set_temporary_text("File saved", 3.0, 0.5)

func _on_h_box_container_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			following = event.pressed
			dragging_start_position = get_global_mouse_position()

func _on_button_min_pressed():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

func _on_button_pin_pressed():
	var a = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP)
	if a == false:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
		$MainWindow/HBoxContainer/ButtonPin.text = '           '
		set_temporary_text("Pinned", 3.0, 0.5)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, false)
		$MainWindow/HBoxContainer/ButtonPin.text = '          '

func load_file(path: String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			$MainWindow/MarginContainer/TextEdit.text = content
			file.close()
			current_file = path
			update_window_title()
			var text = 'File loaded'
			set_temporary_text("File loaded", 3.0, 0.5)
		else:
			set_temporary_text("Failed to open", 3.0, 0.5)
	else:
		set_temporary_text("File does not exist", 3.0, 0.5)

func set_temporary_text(text: String, duration: float = 3.0, fade_time: float = 0.5):
	if tween:
		tween.kill()
	$MainWindow/HBoxContainer/LabelStatus.text = text
	$MainWindow/HBoxContainer/LabelStatus.modulate.a = 0
	tween = create_tween()
	tween.tween_property($MainWindow/HBoxContainer/LabelStatus, "modulate:a", 1.0, fade_time)
	timer.wait_time = duration - fade_time
	timer.one_shot = true
	timer.start()
	if not timer.timeout.is_connected(fade_out):
		timer.timeout.connect(fade_out)

func fade_out():
	tween = create_tween()
	tween.tween_property($MainWindow/HBoxContainer/LabelStatus, "modulate:a", 0.0, 0.5)
	tween.tween_callback(clear_text)
	
func clear_text():
	$MainWindow/HBoxContainer/LabelStatus.text = ''

func update_color_pickers():
	color_picker_fg.color = colorFG
	color_picker_bg.color = colorBG
	color_picker_2.color = color2

func set_colors(new_fg: Color = Color(), new_bg: Color = Color(), new_2: Color = Color()):
	if new_fg == Color() and new_bg == Color() and new_2 == Color():
		var current_colors = get_colors()
		colorFG = current_colors["fg"]
		colorBG = current_colors["bg"]
		color2 = current_colors["2"]
	else:
		colorFG = new_fg
		colorBG = new_bg
		color2 = new_2

func get_colors() -> Dictionary:
	return {
		"fg": color_picker_fg.color,
		"bg": color_picker_bg.color,
		"2": color_picker_2.color
	}

func on_fg_color_changed(new_color: Color):
	colorFG = new_color

func on_bg_color_changed(new_color: Color):
	colorBG = new_color

func on_2_color_changed(new_color: Color):
	color2 = new_color

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_settings()
		get_tree().quit()

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE_PATH)
	
	if err == OK:
		check_button.button_pressed = config.get_value("Settings", "minimap_enabled", false)
		text_edit.minimap_draw = check_button.button_pressed
		colorFG = config.get_value("colors", "fg", Color.WHITE)
		colorBG = config.get_value("colors", "bg", Color.BLACK)
		color2 = config.get_value("colors", "2", Color.BLACK)
		font_path = config.get_value("Settings", "font_path", "")
		font_s = config.get_value("Settings", "fs", font_s)
		
		var window_size = config.get_value("window", "size", Vector2i(1024, 600))
		var window_position = config.get_value("window", "position", Vector2i(100, 100))
		
		get_window().size = window_size
		get_window().position = window_position
	else:
		check_button.button_pressed = false
		text_edit.minimap_draw = false

func save_settings():
	var config = ConfigFile.new()
	
	config.set_value("Settings", "minimap_enabled", check_button.button_pressed)
	config.set_value("Settings", "font_path", font_path)
	config.set_value("colors", "fg", colorFG)
	config.set_value("colors", "bg", colorBG)
	config.set_value("colors", "2", color2)
	config.set_value("window", "size", get_window().size)
	config.set_value("window", "position", get_window().position)
	config.set_value("Settings", "fs", font_s)
	
	var err = config.save(CONFIG_FILE_PATH)
	if err != OK:
		set_temporary_text("Failed to save settings", 3.0, 0.5)


func _on_button_apply_pressed():
	set_colors()
	
	set_global_colors(colorFG, colorBG, color2)
	force_update_controls(get_tree().root)
	change_panel_color()
	setup_custom_colors()
	apply_font_size()
	save_settings()
	set_temporary_text("Settings applied", 3.0, 0.5)


func _on_button_close_pressed():
	$PanelOptions.visible = !visible
	set_temporary_text("Settings saved", 3.0, 0.5)
	
		  

func set_global_colors(colorFG: Color, colorBG: Color, color2: Color):
	var current_theme = get_tree().root.theme
	if not current_theme:
		current_theme = Theme.new()
	
	var new_theme = current_theme.duplicate()
	
	var fg_controls = [ "Label", "LineEdit", "TextEdit", "RichTextLabel"]
	for control in fg_controls:
		new_theme.set_color("font_color", control, colorFG)
		new_theme.set_color("font_focus_color", control, colorFG)
	
	new_theme.set_color("font_color", "PopupMenu", color2)
	
	var color2_controls = ["Label", "LineEdit", "TextEdit", "RichTextLabel", "PopupMenu"]
	for control in color2_controls:
		new_theme.set_color("font_color_selected", control, color2)
		new_theme.set_color("font_hover_color", control, color2)
		new_theme.set_color("font_pressed_color", control, color2)
	
	new_theme.set_color("font_hover_color", "PopupMenu", colorFG)
	new_theme.set_color("font_pressed_color", "PopupMenu", colorBG)
	new_theme.set_color("minimap_highlight_color", "TextEdit", color2)
	

	get_tree().root.theme = new_theme

func force_update_controls(node: Node):
	if node is Control:
		node.queue_redraw()
	for child in node.get_children():
		force_update_controls(child)

func change_panel_color():
	var color_base = Color(randf(), randf(), randf())
	
	var current_theme = get_theme() if get_theme() else Theme.new()
	var new_theme = current_theme.duplicate()
	
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = colorBG
	new_theme.set_stylebox("panel", "Panel", panel_style)
	
	var button_states = ["normal", "hover", "pressed", "focus"]
	for state in button_states:
		var button_style = StyleBoxFlat.new()
		button_style.bg_color = colorBG
		button_style.border_width_bottom = 2
		button_style.border_color = color2
		button_style.content_margin_top = 8
		button_style.content_margin_bottom = 0
		new_theme.set_stylebox(state, "Button", button_style)
	new_theme.set_color("font_color", "Button", colorFG)
	new_theme.set_color("font_hover_color", "Button", color2)
	new_theme.set_color("font_focus_color", "Button", color2)
	
	var popup_style = StyleBoxFlat.new()
	popup_style.bg_color = colorBG
	new_theme.set_stylebox("panel", "PopupMenu", popup_style)
	
	var popup_hover_style = StyleBoxFlat.new()
	popup_hover_style.bg_color = color2
	new_theme.set_stylebox("hover", "PopupMenu", popup_hover_style)
	
	var lineedit_style = StyleBoxFlat.new()
	lineedit_style.bg_color = colorBG
	
	lineedit_style.border_width_bottom = 2 
	lineedit_style.border_color = color2

	lineedit_style.content_margin_bottom = 2	
	new_theme.set_stylebox("normal", "LineEdit", lineedit_style)
	new_theme.set_stylebox("focus", "LineEdit", lineedit_style)
	
	var hscrollbar_style = StyleBoxFlat.new()
	hscrollbar_style.bg_color = color2
	hscrollbar_style.bg_color.a = 0.5
	new_theme.set_stylebox("grabber", "HScrollBar", hscrollbar_style)
	new_theme.set_stylebox("grabber_highlight", "HScrollBar", hscrollbar_style)
	new_theme.set_stylebox("grabber_pressed", "HScrollBar", hscrollbar_style)
	
	new_theme.set_stylebox("grabber", "VScrollBar", hscrollbar_style)
	new_theme.set_stylebox("grabber_highlight", "VScrollBar", hscrollbar_style)
	new_theme.set_stylebox("grabber_pressed", "VScrollBar", hscrollbar_style)

	new_theme.default_font = load(font_path)
	
	$MainWindow/HBoxContainer/VBoxContainer/LabelTitle.add_theme_color_override("font_color", color2)
	$MainWindow/HBoxContainer/VBoxContainer/LabelPath.add_theme_color_override("font_color", Color(color2.r, color2.g, color2.b, 0.5))
	$MainWindow/HBoxContainer/LabelStatus.add_theme_color_override("font_color", color2)
	$PanelFindUi/HBoxContainer/LineEditFind.add_theme_color_override("font_placeholder_color", Color(colorFG.r, colorFG.g, colorFG.b, 0.3))
	$MainWindow/MarginContainer/TextEdit.add_theme_color_override("caret_color", colorFG)
	
	theme = new_theme
	queue_redraw()
	

func _on_checkbox_toggled(button_pressed: bool):
	$MainWindow/MarginContainer/TextEdit.minimap_draw = button_pressed

func _on_check_button_pressed():
	text_edit.minimap_draw = !text_edit.minimap_draw

func _check_status():
	$MainWindow/MarginContainer/TextEdit.minimap_draw = check_button.button_pressed


func _on_button_pressed():
	$FileDialogFont.popup_centered(Vector2(420, 420))

func on_font_selected(path):
	font_path = path
	
	set_temporary_text("Font set", 3.0, 0.5)
	save_settings()
	
func _on_spin_box_value_changed(new_value):
	font_s = new_value

func apply_font_size():
	var current_font = text_edit.get_theme_font("normal_font", "TextEdit")
	var font_variation = FontVariation.new()
	font_variation.set_base_font(current_font)
	font_variation.set_variation_embolden(0.0) 
	font_variation.set_variation_transform(Transform2D.IDENTITY)
	font_variation.set_spacing(TextServer.SPACING_TOP, 0)
	font_variation.set_spacing(TextServer.SPACING_BOTTOM, 0)
	
	text_edit.add_theme_font_size_override("font_size", font_s)
	text_edit.add_theme_font_override("normal_font", font_variation)

func setup_option_button():
	option_button.clear() 
	option_button.add_item("Current")
	option_button.add_item("Default Dark")
	option_button.add_item("Default Light")
	option_button.add_item("GruvDark Red")
	option_button.add_item("GruvLight Red")
	option_button.add_item("Catppuccin")
	option_button.add_item("Solarized")
	option_button.add_item("Bro64")
	

func _on_option_button_item_selected(index: int):
	set_colors_options(index)

func set_colors_options(index: int):
	var color2: Color
	
	match index:
		0:  # Default
			color_picker_fg.color = colorFG
			color_picker_bg.color = colorBG
			color2 = color2
		1:  # Default D
			color_picker_fg.color = Color(0.9451, 0.9451, 0.9451, 1)
			color_picker_bg.color = Color(0.1529, 0.1529, 0.1529, 1)
			color2 = Color(0.1373, 0.3843, 0.7059, 1)
		2:  # Default L
			color_picker_fg.color = Color(0.102, 0.102, 0.102, 1)
			color_picker_bg.color = Color(0.9373, 0.9608, 0.9765, 1)
			color2 = Color(0.1373, 0.3843, 0.7059, 1)
		3:  # GruvDarkRed
			color_picker_fg.color = Color(0.9137, 0.8549, 0.7098, 1) 
			color_picker_bg.color = Color(0.1176, 0.1255, 0.1294, 0.9)
			color2 = Color(0.7373, 0.2275, 0.1451, 1)
		4:  # GruvLightRed
			color_picker_fg.color = Color(0.2314, 0.2196, 0.2118, 1)
			color_picker_bg.color = Color(0.9412, 0.8941, 0.749, 1)
			color2 = Color(0.7373, 0.2275, 0.1451, 1)
		5:  # catppuccin 
			color_picker_fg.color = Color(0.8431, 0.8549, 0.8784, 1)
			color_picker_bg.color = Color(0.1176, 0.1176, 0.1608, 1)
			color2 = Color(0.9176, 0.8667, 0.6275, 1)
		6:  # Solarized
			color_picker_fg.color = Color(0.5765, 0.6314, 0.6314, 1)
			color_picker_bg.color = Color(0, 0.1686, 0.2118, 1)
			color2 = Color(0.1647, 0.6314, 0.5961, 1)
		7:  # bro
			color_picker_fg.color = Color(0.8157, 0.8157, 0.8157, 1)
			color_picker_bg.color = Color(0, 0, 0, 1)
			color2 = Color(0.8118, 0, 0.3922, 1)
	
	if color_picker_2:
		color_picker_2.color = color2
	else:
		pass
	
	
func update_scrollbar_style():
	var current_theme = get_theme() if get_theme() else Theme.new()
	var new_theme = current_theme.duplicate()
	
	var scroll_types = ["HScrollBar", "VScrollBar"]
	var style_names = ["grabber", "grabber_highlight", "grabber_pressed", "scroll"]
	
	for scroll_type in scroll_types:
		for style_name in style_names:
			var new_style = StyleBoxFlat.new()
			new_style.draw_center = true
			
			match style_name:
				"grabber", "grabber_highlight":
					new_style.bg_color = colorFG
				"grabber_pressed", "scroll":
					new_style.bg_color = colorBG
			
			
			new_theme.set_stylebox(style_name, scroll_type, new_style)

	theme = new_theme


func modify_context_menu():
	var menu = text_edit.get_menu()
	
	if menu:
		var item_count = menu.item_count
		
		for i in range(4):
			if item_count > 0:
				menu.remove_item(item_count - 1)
				item_count -= 1


func toggle_scrollbars():
	text_edit.scroll_fit_content_height = not text_edit.scroll_fit_content_height
	
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY if text_edit.wrap_mode == TextEdit.LINE_WRAPPING_NONE else TextEdit.LINE_WRAPPING_NONE
	
	text_edit.queue_redraw()

func move_pin_button_if_macos():
	if OS.get_name() == "macOS":
		var child_count = hbox_container.get_child_count()
		
		hbox_container.move_child(button_pin, child_count - 1)
		
	else:
		pass
	pass

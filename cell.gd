class_name Cell
extends Button

const IMAGE_X = preload("res://x-transparent-background-red.png")
var x: int;
var y: int;
var is_pressed: bool;
var is_crossed: bool;
signal pressed_change

# Called when the node enters the scene tree for the first time.
func _init(x_coord: int, y_coords: int) -> void:
	custom_minimum_size = Vector2(50, 50)
	x = x_coord;
	y = y_coords;
	set_style_normal()
	is_pressed = false;
	is_crossed = false;
	expand_icon = true;
	gui_input.connect(_on_button_gui_input)
	mouse_entered.connect(_on_mouse_entered)

func _on_button_gui_input(event):
	if event is not InputEventMouseButton: return # Only handle clicks

	# If button was pressed, doesn't wait for unpress
	if event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT: _on_left_click_press()
		elif event.button_index == MOUSE_BUTTON_RIGHT: _on_right_click_press()

func _on_left_click_press():
	print("Button pressed: x: ",x,", y: ",y, ", grid-index: ", get_index(), ", pressed?: ", is_pressed)
	if is_crossed: return; # Do nothing if cell is crossed
	
	# Update pressed state and colors
	is_pressed = not is_pressed
	if is_pressed: set_style_dark()
	else: set_style_normal()
	
	# Emit signal when button pressed status changes
	pressed_change.emit()

func _on_right_click_press():
	print("Right clicked: x: ",x,", y: ",y, ", grid-index: ", get_index(), ", pressed?: ", is_pressed)
	if is_pressed: return; # Do nothing if cell is pressed
	
	is_crossed = not is_crossed
	if is_crossed: icon = IMAGE_X
	else: icon = null

func _on_mouse_entered():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): _on_left_click_press()
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): _on_right_click_press()

func set_style_normal():
	# Color for unpressed button
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(1.0, 1.0, 1.0)
	style_normal.border_color = Color(0.444, 0.432, 0.432, 0.988)
	style_normal.border_width_left = 2
	style_normal.border_width_right = 2
	style_normal.border_width_top = 2
	style_normal.border_width_bottom = 2
	add_theme_stylebox_override("normal", style_normal)
	
	# Hover color for unpressed button
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.537, 0.537, 0.537, 1.0)
	add_theme_stylebox_override("hover", style_hover)

func set_style_dark():
	# Color for pressed button
	var style_dark =  StyleBoxFlat.new()
	style_dark.bg_color = Color(0.0, 0.0, 0.0, 1.0)
	style_dark.border_color = Color(0.181, 0.175, 0.175, 0.988)
	style_dark.border_width_left = 2
	style_dark.border_width_right = 2
	style_dark.border_width_top = 2
	style_dark.border_width_bottom = 2
	add_theme_stylebox_override("normal", style_dark)
	
	# Hover color for pressed button
	var style_hover_dark = StyleBoxFlat.new()
	style_hover_dark.bg_color = Color(0.162, 0.162, 0.162, 1.0)
	add_theme_stylebox_override("hover", style_hover_dark)

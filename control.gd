extends Control

const boardWidth = 8;
const boardHeight = 8;
const numOfCorrectCells = 40;
var board = [];
var correctCells = [];
var columnClues = {}
var rowClues = {}
@onready var grid = $GridContainer
const IMAGE_X = preload("res://x-transparent-background-red.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_board();
	draw_board();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_board():
	# Check if numOfCorrectCells is valid, to prevent infinite loop/errors
	if numOfCorrectCells > boardHeight * boardWidth or numOfCorrectCells < 0:
		print("Invalid number of correct cells! (", numOfCorrectCells, ")");
		return
	
	
	# Generate random cells, store in correctCells
	while len(correctCells) < numOfCorrectCells:
		var randCell = [randi_range(0,boardHeight-1), randi_range(0, boardWidth-1)];
		if randCell not in correctCells: correctCells.append(randCell)
	
	
	# Fill board with right and wrong cells: 0 - incorrect, 1 - correct
	for i in range(boardHeight):
		board.append([])
		for j in range(boardWidth):
			if [i, j] in correctCells: board[i].append(1);
			else: board[i].append(0);
	
	
	# Calculate the clues for each row and column
	for i in range(boardHeight):
		rowClues[i] = []
		var sum = 0
		for val in board[i]:
			if val == 1: sum += 1;
			elif sum > 0:
				rowClues[i].append(sum)
				sum = 0
		if sum > 0: rowClues[i].append(sum) # Check final time after we exit loop
		if not rowClues[i]: rowClues[i].append(0) # If array is empty, add 0
	
	for i in range(boardWidth):
		columnClues[i] = []
		var sum = 0
		for j in range(boardHeight):
			var val = board[j][i]
			if val == 1: sum += 1;
			elif sum > 0:
				columnClues[i].append(sum)
				sum = 0
		if sum > 0: columnClues[i].append(sum)
		if not columnClues[i]: columnClues[i].append(0) # If array is empty, add 0
	
	# Print (for debugging purposes)
	print("correctCells: ", correctCells)
	for b in board:
		print(b)
	print("rowClues: ", rowClues)
	print("columnClues: ", columnClues)

func draw_board():
	grid.columns = boardWidth+1;
	
	for y in range(boardHeight + 1): # + 1 for the extra row & column of labels
		for x in range(boardWidth + 1):
			# Leave top left corner empty
			if x == 0 and y == 0:
				grid.add_child(Label.new());
				continue;
			
			# First row for labels
			if y == 0:
				var label = Label.new()
				label.text = str('\n'.join(columnClues[x-1]))
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				grid.add_child(label)
				continue;
				
			# First colum for labels
			if x == 0:
				var label = Label.new()
				label.text = str('   '.join(rowClues[y-1]))
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				grid.add_child(label)
				continue;
			
			var val = board[y-1][x-1]
			var c = Cell.new(x, y)
			#var button = Button.new()
			#button.custom_minimum_size = Vector2(50,50)
			#button.add_theme_stylebox_override("normal", get_button_style("normal"))
			#button.add_theme_stylebox_override("hover", get_button_style("hover"))
			#button.set_meta("pressed", false)
			#button.set_meta("crossed", false)
			#button.gui_input.connect(_on_button_gui_input.bind(x, y, button))
			#button.expand_icon = true; # Resize image to fit in button
			grid.add_child(c);
			c.pressed.connect(check_win)

func get_button_style(type):
	# Color for unpressed button
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(1.0, 1.0, 1.0)
	style_normal.border_color = Color(0.444, 0.432, 0.432, 0.988)
	style_normal.border_width_left = 2
	style_normal.border_width_right = 2
	style_normal.border_width_top = 2
	style_normal.border_width_bottom = 2
	
	# Hover color for unpressed button
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.537, 0.537, 0.537, 1.0)
	
	# Color for pressed button
	var style_dark =  StyleBoxFlat.new()
	style_dark.bg_color = Color(0.0, 0.0, 0.0, 1.0)
	style_dark.border_color = Color(0.181, 0.175, 0.175, 0.988)
	style_dark.border_width_left = 2
	style_dark.border_width_right = 2
	style_dark.border_width_top = 2
	style_dark.border_width_bottom = 2
	
	# Hover color for pressed button
	var style_hover_dark = StyleBoxFlat.new()
	style_hover_dark.bg_color = Color(0.162, 0.162, 0.162, 1.0)
	
	if type == "normal": return style_normal
	elif type == "hover": return style_hover
	elif type == "dark": return style_dark
	elif type == "hover_dark": return style_hover_dark

func _on_button_gui_input(event, x, y, button):
	if event is not InputEventMouseButton: return # Only handle clicks
	
	# If button was pressed then unpressed, and mouse stayed within button boundaries
	if not event.pressed and button.get_global_rect().has_point(get_global_mouse_position()):
		if event.button_index == MOUSE_BUTTON_LEFT: _on_left_click_press(x, y, button)
		elif event.button_index == MOUSE_BUTTON_RIGHT: _on_right_click_press(x, y, button)

func _on_left_click_press(x, y, button):
	print("Button pressed: x: ",x,", y: ",y, ", grid-index: ",button.get_index(), ", pressed?(meta): ", button.get_meta("pressed"))
	if button.get_meta('crossed'): return; # Do nothing if cell is crossed
	# Update pressed state and colors
	button.set_meta("pressed", not button.get_meta("pressed"))
	if button.get_meta("pressed"):
		button.add_theme_stylebox_override("normal", get_button_style("dark"))
		button.add_theme_stylebox_override("hover", get_button_style("hover_dark"))
	else:
		button.add_theme_stylebox_override("normal", get_button_style("normal"))
		button.add_theme_stylebox_override("hover", get_button_style("hover"))
	
	if check_win(): print('GAME COMPLETE!');

func _on_right_click_press(x, y, button):
	print("Right clicked: x: ",x,", y: ",y, ", grid-index: ",button.get_index(), ", pressed?(meta): ", button.get_meta("pressed"))
	if button.get_meta('pressed'): return; # Do nothing if cell is pressed
	button.set_meta('crossed', not button.get_meta('crossed'));
	if button.get_meta('crossed'):
		button.icon = IMAGE_X
	else:
		button.icon = null

func check_win():
	# Convert x-y coordinates to flat-sequential grid index
	print('CHECKING WIN')
	var correct_indices = []
	for coords in correctCells:
		var index = (boardWidth+1) + ((boardWidth+1) * coords[0]) + coords[1] + 1
		correct_indices.append(index)
	
	# Return false if correct cells and pressed cells don't match exactly
	for child in grid.get_children():
		if child is not Button: continue
		if child.get_index() in correct_indices and not child.is_pressed: return false;
		if child.is_pressed and child.get_index() not in correct_indices: return false;
	
	print('-------------------YOU WIN!!!---------------------')
	return true

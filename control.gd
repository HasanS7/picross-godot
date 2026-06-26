extends Control

# For random board generation ===================
var boardWidth = GameSettings.width;
var boardHeight = GameSettings.height;
var numOfCorrectCells = GameSettings.numOfCorrectCells;
# ===============================================
var board = [];
var correctCells = [];
var columnClues = {}
var rowClues = {}
@onready var grid = $GameCenterContainer/GridContainer
@onready var center_container =  $WinCenterContainer
const IMAGE_X = preload("res://x-transparent-background-red.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_board();
	draw_board();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_board():
	var level_selection = GameSettings.difficulty
	# If file name or valid number entered (1-4), choose a board, otherwise generate random
	if choose_board(level_selection+1):
		calculate_clues()
		find_correct_cells()
		print_board_data()
		return
	
	# Check if numOfCorrectCells is valid, to prevent infinite loop/errors
	if numOfCorrectCells > boardHeight * boardWidth or numOfCorrectCells < 0:
		print("Invalid number of correct cells! (", numOfCorrectCells, ")");
		return
		# DO SOMETHING ELSE HERE, CAUSES ERROR
	
	
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
	
	calculate_clues()
	
	print_board_data()

func calculate_clues():
	# Calculate the clues for each row and column
	for i in range(board.size()):
		rowClues[i] = []
		var sum = 0
		for val in board[i]:
			if val == 1: sum += 1;
			elif sum > 0:
				rowClues[i].append(sum)
				sum = 0
		if sum > 0: rowClues[i].append(sum) # Check final time after we exit loop
		if not rowClues[i]: rowClues[i].append(0) # If array is empty, add 0

	for i in range(board[0].size()):
		columnClues[i] = []
		var sum = 0
		for j in range(board.size()):
			var val = board[j][i]
			if val == 1: sum += 1;
			elif sum > 0:
				columnClues[i].append(sum)
				sum = 0
		if sum > 0: columnClues[i].append(sum)
		if not columnClues[i]: columnClues[i].append(0)

func find_correct_cells():
	for i in board.size():
		for j in board[0].size():
			if board[i][j] == 1: correctCells.append([i, j])

func print_board_data():
	# Print (for debugging purposes)
	print("correctCells: ", correctCells)
	for b in board:
		print(b)
	print("rowClues: ", rowClues)
	print("columnClues: ", columnClues)

func draw_board():
	grid.columns = board[0].size()+1;
	
	for y in range(board.size() + 1): # + 1 for the extra row & column of labels
		for x in range(board[0].size() + 1):
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
			
			var c = Cell.new(x, y)
			# Dynamically sizing the buttons
			c.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			var size = 500 / max(board.size(), board[0].size())
			c.custom_minimum_size = Vector2(size, size)
			
			c.pressed_change.connect(check_win) # Check for win on each new cell click
			grid.add_child(c);

func check_win():
	# Convert x-y coordinates to flat-sequential grid index
	var correct_indices = []
	for coords in correctCells:
		var index = (board[0].size()+1) + ((board[0].size()+1) * coords[0]) + coords[1] + 1
		correct_indices.append(index)
	
	# Return false if correct cells and pressed cells don't match exactly
	for child in grid.get_children():
		if child is not Button: continue
		if child.get_index() in correct_indices and not child.is_pressed: return false;
		if child.is_pressed and child.get_index() not in correct_indices: return false;
	
	# Victory sequence
	print('-------------------YOU WIN!!!---------------------')
	center_container.scale = Vector2(0,0)
	center_container.show()
	var tween = create_tween()

	tween.tween_property(
		center_container,
		"scale",
		Vector2(1,1),
		0.3
	)
	
	return true

func choose_board(difficulty):
	# Load from JSON file
	if difficulty == 5:
		load_board_from_file(GameSettings.gameFilePath)
		return true
		
	# Smiley-face
	elif difficulty == 1:
		board = [
			[0,0,0,0,0,0],
			[0,1,0,0,1,0],
			[0,0,0,0,0,0],
			[1,0,0,0,0,1],
			[0,1,1,1,1,0],
			[0,0,0,0,0,0]
		]
		return true # Return true if a board was selected
	
	# Heart
	elif difficulty == 2:
		board = [
			[0,1,0,0,0,1,0],
			[1,1,1,0,1,1,1],
			[1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1],
			[0,1,1,1,1,1,0],
			[0,0,1,1,1,0,0],
			[0,0,0,1,0,0,0]
		]
		return true
	
	# Star
	elif difficulty == 3:
		board = [
			[0, 0, 1, 0, 0],
			[0, 1, 1, 1, 0],
			[1, 1, 1, 1, 1],
			[0, 1, 1, 1, 0],
			[0, 1, 0, 1, 0]
		]
		return true
	
	# Alien
	elif difficulty == 4:
		board = [
			[0, 0, 1, 0, 0, 0, 0, 1, 0, 0],
			[0, 0, 0, 1, 0, 0, 1, 0, 0, 0],
			[0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
			[0, 1, 1, 0, 1, 1, 0, 1, 1, 0],
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 0, 1, 1, 1, 1, 1, 1, 0, 1],
			[1, 0, 1, 0, 0, 0, 0, 1, 0, 1],
			[0, 0, 0, 1, 1, 1, 1, 0, 0, 0]
		]
		return true
	
	else: return false

func load_board_from_file(file_path):
	if not FileAccess.file_exists(file_path):
		print("Error: Level file not found!")
		return
		
	# Open and parse the JSON file
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		board = json.data
		print("Successfully loaded Picross matrix: ", board)
	else:
		print("JSON Parse Error: ", json.get_error_message())

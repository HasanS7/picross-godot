extends Control

@onready var difficulty_option = $CenterContainer/Panel/MarginContainer/VBoxContainer/OptionButton
@onready var custom_settings_container = $CenterContainer/Panel/MarginContainer/VBoxContainer/CustomSettingsContainer
@onready var width_spinbox = $CenterContainer/Panel/MarginContainer/VBoxContainer/CustomSettingsContainer/VBoxContainer/WidthRow/WSpinBox
@onready var height_spinbox = $CenterContainer/Panel/MarginContainer/VBoxContainer/CustomSettingsContainer/VBoxContainer/HeightRow/HSpinBox
@onready var correct_cells_spinbox = $CenterContainer/Panel/MarginContainer/VBoxContainer/CustomSettingsContainer/VBoxContainer/NumCorrectCellsRow/CSpinBox
@onready var load_level_row = $CenterContainer/Panel/MarginContainer/VBoxContainer/LoadLevelRow
@onready var load_level_label = $CenterContainer/Panel/MarginContainer/VBoxContainer/LoadLevelRow/LevelNameLabel
@onready var level_file_dialog = $LevelFileDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	difficulty_option.add_item("Level 1")
	difficulty_option.add_item("Level 2")
	difficulty_option.add_item("Level 3")
	difficulty_option.add_item("Level 4")
	difficulty_option.add_item("Load File...")
	difficulty_option.add_item("Custom")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Start the game (Play button)
func _on_play_pressed() -> void:
	# If no file is loaded while in load file mode, do nothing
	if difficulty_option.selected == 4 and not GameSettings.gameFilePath:
		print('No file selected')
		return
	
	print('Difficulty: ', difficulty_option.selected)
	# Store values in external file
	GameSettings.difficulty = difficulty_option.selected
	GameSettings.width = int(width_spinbox.value)
	GameSettings.height = int(height_spinbox.value)
	GameSettings.numOfCorrectCells = int(correct_cells_spinbox.value)
	
	get_tree().change_scene_to_file("res://main.tscn")

# Quit game
func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_option_button_item_selected(index: int) -> void:
	if index == 5: custom_settings_container.show()
	else: custom_settings_container.hide()
	
	if index == 4: load_level_row.show()
	else: load_level_row.hide()

func _on_load_level_button_pressed() -> void:
	level_file_dialog.popup_centered()

func _on_level_file_dialog_file_selected(path: String) -> void:
	GameSettings.gameFilePath = path
	load_level_label.text = path.get_file()

# Update correct cells spinbox max accordingly whenever height or width values change
func _on_w_spin_box_value_changed(value: float) -> void:
	correct_cells_spinbox.max_value = width_spinbox.value * height_spinbox.value
func _on_h_spin_box_value_changed(value: float) -> void:
	correct_cells_spinbox.max_value = width_spinbox.value * height_spinbox.value

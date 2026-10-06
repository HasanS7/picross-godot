extends Control

@onready var width_spinbox = $OptionsHBoxContainer/WidthRow/WSpinBox
@onready var height_spinbox = $OptionsHBoxContainer/HeightRow/HSpinBox
@onready var threshold_spinbox = $OptionsHBoxContainer/ThresholdRow/TSpinBox
@onready var text_area = $TextEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_area.editable = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func run_python_script(source_file_path: String, width: int, height: int, threshold: int, export: bool) -> void:
	# Pathing for exported games
	var interpreter_path: String = "python3" # Or absolute path to a local bundle
	var script_path: String = ProjectSettings.globalize_path("res://scripts/image_processing.py")
	
	var arguments: Array[String] = [script_path]
	var output: Array = []
	
	# Apend arguments array with actual arguments
	arguments.append(source_file_path)
	arguments.append(str(width))
	arguments.append(str(height))
	arguments.append(str(threshold))
	arguments.append(str(export))
	
	var exit_code = OS.execute(interpreter_path, arguments, output)

	if exit_code == OK:
		print("Python finished successfully!")
		print("Received Output: ", output)
		# Set the TextEdit text to the result
		var out_text = output[0]
		out_text.replace("\r\n","\n")
		text_area.text = out_text
		
		if export:
			# Set the gameFilePath variable to the JSON file we just exported
			var fname = GameSettings.sourceFilePath.split('/')[-1].split('.')[0] + '.json'
			GameSettings.gameFilePath = "res://Custom_Levels/" + fname
		
	else:
		print("Failed to run Python script. Exit code: ", exit_code)
		print("Received Output: ", output)



func _on_generate_button_pressed() -> void:
	print("Executing the python script to render image...")
	run_python_script(GameSettings.sourceFilePath, width_spinbox.value, height_spinbox.value, threshold_spinbox.value, false)
	$ExportButton.visible = true; # Allow the export button to be pressed after 1 image generated


func _on_export_button_pressed() -> void:
	print("Exporting image to JSON level file...")
	run_python_script(GameSettings.sourceFilePath, width_spinbox.value, height_spinbox.value, threshold_spinbox.value, true)
	
	# Start game with JSON file
	GameSettings.width = int(width_spinbox.value)
	GameSettings.height = int(height_spinbox.value)
	get_tree().change_scene_to_file("res://gameScene.tscn")



func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mainMenu.tscn")
	

extends Control

var main_scene = preload("res://main.tscn")

@onready var level_dropdown: OptionButton = $GameConfig/CenterContainer/VBoxContainer/Level/LevelChoice
@onready var npc_count_spinbox: SpinBox = $GameConfig/CenterContainer/VBoxContainer/NPCCount/SpinBox
@onready var start_game_button: TextureButton = get_node("GameConfig/CenterContainer/VBoxContainer/Start Game")
# To load which image to render or something
func _ready() -> void:
	var all_levels = GlobalState.LEVEL_LIST
	for level_name in all_levels:
		level_dropdown.add_item(level_name)

# Maybe if I want to render a background or something versus an image
func _process(_delta: float) -> void:
	pass

# Button functions
# Wired up in Godot directly
func _on_play_pressed() -> void:
	# Show the settings menu and play from there
	$HomeStart.hide()
	$GameConfig.show()

func _on_settings_pressed() -> void:
	pass


func _on_how_to_play_pressed() -> void:
	print()

func _on_how_to_play_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if !GlobalState.no_randomize:
			GlobalState.no_randomize = true
			$QAInfo.show()
		else:
			GlobalState.no_randomize = false
			$QAInfo.hide()
		print("QA toggled")

func _on_credits_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_game_pressed() -> void:
	start_game_button.get_node("Label").text = "Loading..."

	# save the settings
	var npc_count_int = int(npc_count_spinbox.value)
	GlobalState.TOTAL_NPCS = npc_count_int
	var selected_level_idx = level_dropdown.selected
	GlobalState.SELECTED_LEVEL = level_dropdown.get_item_text(selected_level_idx)

	var main_node = main_scene.instantiate()
	get_parent().add_child(main_node)
	self.queue_free()

# TODO: Reset the spin box / if it's max, set to max of the level
func _on_level_choice_item_selected(index: int) -> void:
	var level_name = level_dropdown.get_item_text(index)
	npc_count_spinbox.reset(level_name)

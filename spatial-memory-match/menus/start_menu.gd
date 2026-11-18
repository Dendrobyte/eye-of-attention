extends Control

var main_scene = preload("res://main.tscn")

@onready var level_dropdown: OptionButton = $GameConfig/CenterContainer/VBoxContainer/Level/LevelChoice
@onready var npc_count_spinbox: SpinBox = $GameConfig/CenterContainer/VBoxContainer/NPCCount/SpinBox

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
	pass


func _on_credits_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_game_pressed() -> void:
	# just show / hide this
	var main_node = main_scene.instantiate()
	get_parent().add_child(main_node)
	self.queue_free()
	pass # Replace with function body.

# TODO: Reset the spin box / if it's max, set to max of the level
func _on_level_choice_item_selected(index: int) -> void:
	var level_name = level_dropdown.get_item_text(index)
	npc_count_spinbox.reset(level_name)

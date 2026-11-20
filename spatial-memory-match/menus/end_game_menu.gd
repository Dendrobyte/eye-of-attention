extends Control

func _ready() -> void:
	$CenterContainer/VBoxContainer/TimeReport.text += GlobalState.show_time_elapsed()
	$CenterContainer/VBoxContainer/Stars.text += str(GlobalState.STARS) + " / 3"
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			pass

# Wired up via engine
func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/start_menu.tscn")
	# get_tree().root.get_node("Main").queue_free() # I'd much rather this be on the main script as reset_main or something
	queue_free()

func _on_quit_game_pressed() -> void:
	get_tree().quit()

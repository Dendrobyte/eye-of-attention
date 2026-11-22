extends Control

@onready var music_player = get_parent().get_node("LevelManager/Music")

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if !GlobalState.IS_GAME_RUNNING:
		return
	if event.is_action_pressed("ESCAPE"):
		toggle_menu()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			pass

var in_menu = false
func toggle_menu():
	if in_menu:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		GlobalState.resume_game_stopwatch()
		music_player.play()
		hide()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		GlobalState.pause_game_stopwatch()
		music_player.stop()
		show()
	in_menu = !in_menu

# Wired up via engine
func _on_resume_pressed() -> void:
	toggle_menu()

func _on_quit_game_pressed() -> void:
	get_tree().quit()

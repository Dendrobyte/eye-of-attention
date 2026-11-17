extends Control

var main_scene = preload("res://main.tscn")

# To load which image to render or something
func _ready() -> void:
	pass

# Maybe if I want to render a background or something versus an image
func _process(_delta: float) -> void:
	pass

# Button functions
# Wired up in Godot directly
func _on_play_pressed() -> void:
	# do intermediate config menu first, same control node is fine
	# just show / hide this
	var main_node = main_scene.instantiate()
	get_parent().add_child(main_node)
	self.queue_free()

func _on_settings_pressed() -> void:
	pass


func _on_how_to_play_pressed() -> void:
	pass


func _on_credits_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()

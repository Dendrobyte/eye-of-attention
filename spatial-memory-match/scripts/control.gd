extends Control

var cursor_pos
func _ready():
	cursor_pos = Vector2(size.x / 2, size.y / 2)

func _draw():
	draw_circle(Vector2(cursor_pos.x, cursor_pos.y), 6.3905, Color.PALE_GREEN)

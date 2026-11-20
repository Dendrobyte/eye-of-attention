extends SpinBox

# I want this one to have a script since its pretty isolated behavior

# Temporary for game jam. Remember to change these if the name or count changes!
var level_max_npcs = {
	"prototype_map": 3,
	"tutorial": 3,
	"first_floor": 8,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# it's been starting on first floor lately
	step = 1
	min_value = 2
	max_value = 8

# Called by level change function to reset to 2 and set max value to the selected map
func reset(level_name):
	self.max_value = level_max_npcs[level_name]

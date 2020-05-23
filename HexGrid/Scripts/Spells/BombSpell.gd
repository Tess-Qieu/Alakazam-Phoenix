extends Spell
class_name BombSpell


var impact_range = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init():
	miniature = load("res://Prefabs/Character/Spells/Missile64.png")
	cast_range = 4

func display_touched_cells(map, origin_cell, target_cell, color_key):
	var line
	if map.is_in_fov(origin_cell, cast_range, target_cell):
		line = map.display_zone(target_cell, impact_range, color_key)
	return line

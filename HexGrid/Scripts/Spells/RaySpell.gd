extends Spell
class_name RaySpell


func _ready():
	print("Cannon ball!")

func _init():
	miniature = load("res://Prefabs/Character/Spells/Cannon.png")
	cast_range = [0, 10]
	fov_type = 'straight_lines'

#func display_touched_cells(map, origin_cell, target_cell, color_key):
#	var line
#	if map.is_in_fov(origin_cell, cast_range, target_cell):
#		line = map.display_line(origin_cell, target_cell, color_key)
#	return line

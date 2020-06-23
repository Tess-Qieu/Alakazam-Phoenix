extends Spell
class_name RaySpell


#func _ready():
#	print("Cannon ball!")

func _init():
	miniature = load("res://Prefabs/Character/Spells/Cannon.png")
	cast_range = [0, 10]
	damage_amount = [28,32]
	fov_type = 'straight_lines'

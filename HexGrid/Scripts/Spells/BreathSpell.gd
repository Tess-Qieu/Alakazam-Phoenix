extends Spell
class_name BreathSpell


## Called when the node enters the scene tree for the first time.
#func _ready():
#	print("BreathSpell !")
	
func _init():
	miniature = load("res://Prefabs/Character/Spells/Flamethrower64.png")
	damage_amount = [8,13]
	cast_range = [2,4] #First value is cast range, second is triangle height
	fov_type = 'hexa_points'
	impact_type = 'breath'

extends Spell
class_name BombSpell


var impact_range = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init():
	miniature = load("res://Prefabs/Character/Spells/Missile64.png")
	cast_range = [2,4]
	impact_type = 'zone'

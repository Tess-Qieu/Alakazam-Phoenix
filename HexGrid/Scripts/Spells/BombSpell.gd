extends Spell
class_name BombSpell


var impact_range = 2


## Called when the node enters the scene tree for the first time.
#func _ready():
#	print("BombSpell !")
	
func _init():
	miniature = load("res://Prefabs/Character/Spells/Missile64.png")
	damage_amount = [10,15]
	cast_range = [2,4]
	impact_type = 'zone'
	start_cooldown = 4

extends Spell
class_name BombSpell


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init():
	miniature = load("res://Prefabs/Character/Spells/Missile64.png")

extends Node
class_name Team

# Color of the Team
var color_key

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_member(character : Character):
	
	if character.get_parent() != null:
		character.get_parent().remove_child(character)
	
	add_child(character)
	character.my_team = self
	character.change_material(color_key)

func has_member(character):
	return character in get_children()

func remove_member(character : Character):
	if has_member(character):
		character.change_material("white")
		character.my_team = null
		remove_child(character)

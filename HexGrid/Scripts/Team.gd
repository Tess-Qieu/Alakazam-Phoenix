extends Node
class_name Team

# Color of the Team
var color_key
var user_id

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_member(character : Character):
	if character.get_parent() != null:
		character.get_parent().remove_child(character)
	
	add_child(character)
	character.change_material(color_key)

func has_member(character):
	return character in get_children()

func remove_member(character : Character):
	if has_member(character):
		character.change_material("white")
		character.my_team = null
		remove_child(character)

func get_member(index : int):
	if index >= 0 and index < get_child_count():
		return get_child(index)

func get_member_by_id(id):
	for elt in get_children():
		if elt.id_character == id:
			return elt
			
	return null # default return if no one is found

func get_all_members():
	return get_children()

func next_turn(data:Dictionary):
	# Update of character info with the provided data
	for character_id in data.keys():
		get_member_by_id(character_id).next_turn(data[character_id])

func is_team_dead():
	return false #HEROES NEVER DIE!

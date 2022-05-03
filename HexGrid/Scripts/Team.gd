extends Node
class_name Team

# Color of the Team
var color_key
var user_id

var size setget ,get_size

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

func get_all_members():
	return get_children()

func is_team_alive():
	var is_team_alive = false
	for member in get_all_members():
		is_team_alive = is_team_alive or member.is_alive()
#		print("Team {0} alive? {1}, member {2}".format([name, is_team_alive, member.name]))
	return is_team_alive

func is_team_dead():
	return not is_team_alive()

func get_size():
	return get_all_members().size()

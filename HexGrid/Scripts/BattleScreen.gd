extends Control

var Battle = preload("res://Scenes/Battle.tscn")



## BUTTON EVENTS ##
func _on_ButtonSpell_pressed():
	var battle = get_battle()
	var map = battle.get_node('Map')
	battle.clear_arena()
	battle.fov = map.display_field_of_view(battle.current_character.current_cell, 20)
	battle.state = 'cast_spell'
	
func _on_ButtonClear_pressed():
	get_battle().clear_arena()


## USEFULL FUNCTIONS ##
func get_battle():
	# Only solution to find the node Battle which change name	
	for node in get_children():
		if 'Battle' in node.name:
			return node

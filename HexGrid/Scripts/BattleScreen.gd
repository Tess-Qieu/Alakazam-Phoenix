extends Control

var Character_Info = preload("res://Scenes/GUI/Character_Info.tscn")

func _ready():
	if is_main_scene():
		$Battle.init_game_local()

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

func is_f6(node:Node):
	return node.filename != ProjectSettings.get_setting('application/run/main_scene')

func is_main_scene():
	return get_parent() == get_tree().root 

func add_character_info(character, team):
	var char_info = Character_Info.instance()
	$PanelLeft/VBoxContainer.add_child(char_info)
	char_info.connect_character(character, team)

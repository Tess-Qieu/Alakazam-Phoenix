extends Control

var Team_Container = preload("res://Scenes/GUI/TeamContainer.tscn")

func _ready():
	if is_main_scene():
		$Battle.init_game_local()


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

func add_character_info(character:Character, team:Team):
	
	# Looking through each team container existing. If one has the same name
	#  as the character's team name, the character is added, then an early return
	#  is used.
	for elt in $PanelLeft/ScrollContainer/VBoxContainer.get_children():
		if elt.get_team_name() == team.name:
			elt.add_teammate(character)
			return
	
	# If we get here, the character hasn't been add to a team
	# A new team container is instanciated and the character is added
	var new_team = Team_Container.instance()
	# Addition of the new team to the view
	$PanelLeft/ScrollContainer/VBoxContainer.add_child(new_team)
	
	new_team.config_team(team)
	new_team.add_teammate(character)



## BUTTON EVENTS ##
func _on_ButtonSpell_pressed():
	var battle = get_battle()
	var map = battle.get_node('Map')
	battle.clear_arena()
	battle.fov = map.display_field_of_view(battle.current_character.current_cell, 20)
	battle.state = 'cast_spell'
	
func _on_ButtonClear_pressed():
	get_battle().clear_arena()
	
func _on_ButtonZone_pressed():
	$Battle.state = 'cast_spell'
	$Battle.current_spell = 'zone'

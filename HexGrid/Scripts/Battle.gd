extends Spatial

var RobotCharacter = preload("res://Scenes/Characters/Robot_character.tscn")
var rng = RandomNumberGenerator.new()


var character_selected: Character
var teams = {}
var current_team: Team

var state = 'normal' # ['normal', 'cast_spell', 'movement']
var memory_on_turn = {'move': {}, 'cast spell': {}} # memory of what action have been made by which character this turn
var character_moving


var fov = []
var path_instanced = []
var path_serialized = []




## INITIALISATION / CONTROL GAME ##
func init_battle(grid, teams_infos):
	# Instanciate map and characters
	$Map.instance_map(grid)
	for name in teams_infos.keys():
		_create_team(name, teams_infos[name])

func choose_next_character_selected():
	# if the current_team belongs to the client then we choose the first character from its team
	# else we have to find its team to select a character from it
	if current_team.user_id == Global.user_id:
		_select_character(current_team.get_member(0))
	else:
		for team in teams.values():
			if team.user_id == Global.user_id:
				_select_character(team.get_member(0))

func next_turn(data=null):
	# Select the next current_team and character_selected on the next turn
	# Then reset memory on turn
	choose_next_current_team(data)
	choose_next_character_selected()
	_reset_memory_on_turn()
	clear_arena()



## CHARACTER CREATION/UPDATE ##
func _create_team(team_name, data):
	# Create a team in function of informations in data
	# init the team
	var new_team = Team.new()
	new_team.name = team_name
	new_team.color_key = data['color']
	new_team.user_id = data['user id']
	teams[team_name] = new_team	
	
	for c in data['characters']:
		var character = _create_character(new_team.color_key, 
										c['q'], 
										c['r'],
										c['id character'],
										data['user id'],
										c['health'], 
										c['range displacement'])
		teams[team_name].add_member(character)
		# Addition of a character info on the BattleScreen
		$BattleControl.add_character_info(character, new_team)
	
	add_child(new_team)

func _create_character(team, q, r, id_character, user_id, health, range_displacement):
	var cell = $Map.grid[q][r]
	var character = RobotCharacter.instance()
	character.init(cell, team, id_character, user_id, health, range_displacement, self)
	
	_update_character_cell_references(character, cell)
	add_child(character)
	return character

func _update_character_cell_references(character, new_cell):
	## Update references from cell to character and from character to cell
	# if the character had a cell reference
	if character.current_cell != null:
		# The previous cell forgets the character reference
		character.current_cell.character_on = null
	# The character's new cell reference and kind are update
	character.current_cell = new_cell
	# The new cell gets a reference to the player on it
	new_cell.character_on = character

func _on_character_die(character):
	print('character die')
	character.die(self)






## MAKE MOVE/SPELL##
func _make_character_moving_move_one_step():
	# Movement limitation
	state = 'moving'
	character_moving.move_to(path_instanced.pop_front())

func make_character_move_following_path_valid(character, path_valid):
	# Movement limitation
	character_moving = character
	path_instanced = []
	for coord in path_valid:
		path_instanced += [$Map.grid[coord[0]][coord[1]]]
	_make_character_moving_move_one_step()
	_update_memory_on_turn('move', character)

func make_character_cast_spell(character, cell, damages_infos):
	character.cast_spell(cell, damages_infos)
	fov = []
	clear_arena()
	state = 'normal'
	_update_memory_on_turn('cast spell', character)






## ANIMATION EVENTS ##
func _on_character_movement_finished(character, ending_cell):
	_update_character_cell_references(character, ending_cell)
	if path_instanced.size() == 0:
		state = 'normal'
		character_moving.stop_movement()
		clear_arena()
	else:
		_make_character_moving_move_one_step()





## OBJECT EVENTS ##
func _on_character_clicked(character):
	if not state == 'cast_spell' and _can_player_control_character(character):
		_select_character(character)
	else:
		_ask_cast_spell(character_selected, character.current_cell)

func _on_cell_clicked(cell):
	if state == 'normal':
		if len(path_serialized) > 0 :
			_ask_move(character_selected, path_serialized)
	elif state == 'cast_spell':
		if cell in fov:
			_ask_cast_spell(character_selected, cell)




func _on_cell_hovered(cell):
	if state == 'normal' and _has_not_already_done_action(character_selected, 'move'):
		clear_arena()
		path_serialized = $Map.display_path(character_selected.current_cell, 
								cell, 
								character_selected.current_range_displacement)
	
func _on_character_hovered(character):
	if state == 'normal' and _has_not_already_done_action(character, 'move'):
		clear_arena()
		$Map.display_displacement_range(character.current_cell, 
										character.current_range_displacement)






## ASK FUNCTIONS ##
func _ask_cast_spell(character, cell):
	# Verify that the character hasn't already cast a spell this turn
	# Run ask_cast_spell function if it doesn't
	if not _is_character_turn(character):
		print('Impossible request: not character turn.')
	elif not _has_not_already_done_action(character, 'cast spell'):
		print('Impossible request: character has already cast a spell this turn')
	else:
		ask_cast_spell(character, cell)


func _ask_move(character, path):
	# Verify that the character hasn't already moved this turn
	# Run ask_move function if it doesn't
	if not _is_character_turn(character):
		print('Impossible request: not character turn.')
	elif not _has_not_already_done_action(character, 'move'):
		print('Impossible request: character has already moved this turn')
	else:
		ask_move(character, path)




## INHERITABLED FUNCTIONS ##
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func ask_cast_spell(character, cell):
	pass
	
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func ask_move(character, path):
	pass

func ask_end_turn(): 
	pass

# warning-ignore:unused_argument
func choose_next_current_team(data=null):
	pass











## USEFULL FUNCTIONS ##
func get_character_by_id(id_character):
	var all_characters = []
	for name in teams.keys():
		all_characters += teams[name].get_all_members()
		
	for character in all_characters:
		if character.id_character == id_character:
			return character
	return null

func get_cell_by_coords(q, r):
	return $Map.grid[q][r]
	

func _select_character(character):
	if character_selected != null:
		character_selected.unselect()
	# select character
	if current_team.has_member(character):
		# The client can select only chracter in his own team
		character_selected = character
	clear_arena()
	

func _update_memory_on_turn(action, character):
	memory_on_turn[action][character] = true

func _reset_memory_on_turn():
	for action in memory_on_turn.keys():
		memory_on_turn[action] = {}
		for team in teams.values():
			for character in team.get_all_members():
				memory_on_turn[action][character] = false

func _has_not_already_done_action(character, action):
	return not memory_on_turn[action][character]
	
func _is_character_turn(character):
	return current_team.has_member(character)
	
func _can_player_control_character(character):
	return character.user_id == Global.user_id
	
	
## CLEAR ##
func _color_character_selected_cell():
	character_selected.current_cell.change_material(character_selected.team_color)

func clear_arena():
	state = 'normal'
	$Map.clear()
	if character_selected != null:
		_color_character_selected_cell()

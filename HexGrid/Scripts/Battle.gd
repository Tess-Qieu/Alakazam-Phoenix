extends Spatial

signal ask_move
signal ask_cast_spell

var is_game_local = false


var RobotCharacter = preload("res://Scenes/Characters/Robot_character.tscn")
var teams = {}

var current_character : Character
var character_moving = null
var my_team_name # name of the team the client is controlling

var state = 'normal' # ['normal', 'cast_spell', 'movement']

var fov = []
var path_instanced = []
var path_serialized = []

var rng = RandomNumberGenerator.new()



## INITIALISATION ##
func init(grid, teams_infos, node_battlenetwork):
	# Instanciate map and characters
	$Map.instance_map(grid)
	for name in teams_infos.keys():
		_create_team(name, teams_infos[name])
	
	current_character = teams[my_team_name].get_member(0)
	clear_arena()
	
	if not is_game_local:
		# warning-ignore:return_value_discarded
		connect('ask_move', node_battlenetwork, '_on_ask_move')
		# warning-ignore:return_value_discarded
		connect('ask_cast_spell', node_battlenetwork, '_on_ask_cast_spell')
	
func init_game_local():
	# Generate teams and map, then instanciate them
	# Called only when battlescreen is run with f6
	is_game_local = true
	var teams_infos = {'Local redz': 
						{	'user id': -1,
							'color': 'red',
							'characters': 
								[ {	'health':100, 
									'id character':1, 
									'q':0, 
									'r':0, 
									'range displacement':5, 
									'team_color':'red'
									},
								{	'health':100, 
									'id character':4, 
									'q':1, 
									'r':3, 
									'range displacement':5, 
									'team_color':'red'
									},
								{	'health':100, 
									'id character':5, 
									'q':3, 
									'r':5, 
									'range displacement':5, 
									'team_color':'red'
									}
								]
						},
					'Visiter blues': 
						{	'user id': -1,
							'color': 'blue',
							'characters': 
								[ {	'health':100, 
									'id character':0,
									'q':1, 
									'r':-5, 
									'range displacement':5, 
									'team_color':'blue'
									},
								{	'health':100, 
									'id character':2,
									'q':6, 
									'r':-5, 
									'range displacement':5, 
									'team_color':'blue'
									},
								{	'health':100, 
									'id character':3,
									'q':6, 
									'r':-4, 
									'range displacement':5, 
									'team_color':'blue'
									}
								]
						}
					}
	$Map.generate_grid()
	init($Map.grid, teams_infos, null)
	get_parent().get_node("EndTurn_Widget/Button").connect("pressed",self,"_on_button_pressed")

func _on_button_pressed():
	print("Button pressed!")




## CHARACTER CREATION/UPDATE ##
func _create_team(team_name, data):
	if data['user id'] == Global.user_id:
		# stock the name of his team
		my_team_name = team_name
	
	# init the team
	var new_team = Team.new()
	new_team.name = team_name
	new_team.color_key = data['color']
	teams[team_name] = new_team
	
	for c in data['characters']:
		var character = _create_character(new_team.color_key, 
										c['q'], 
										c['r'],
										c['id character'],
										c['health'], 
										c['range displacement'])
		teams[team_name].add_member(character)
		# Addition of a character info on the BattleScreen
		get_parent().add_character_info(character, new_team)
	
	add_child(new_team)

func _create_character(team, q, r, id_character, health, range_displacement):
	var cell = $Map.grid[q][r]
	var character = RobotCharacter.instance()
	character.init(cell, team, id_character, health, range_displacement, self)
	
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


func make_character_cast_spell(character, cell, damages_infos):
	character.cast_spell(cell, damages_infos)
	fov = []
	clear_arena()
	state = 'normal'





## CLEAR ##
func _color_current_character_cell():
#	if (current_character in teams['blue']):
#		current_character.current_cell.change_material('blue')
#	elif (current_character in teams['red']):
#		current_character.current_cell.change_material('red')
#	else:
	current_character.current_cell.change_material(current_character.team_color)

func clear_arena():
	state = 'normal'
	$Map.clear()
	_color_current_character_cell()









## ANIMATION EVENTS ##
func _on_character_movement_finished(character, ending_cell):
	_update_character_cell_references(character, ending_cell)
	if path_instanced.size() == 0:
		state = 'normal'
		character_moving.stop_movement()
		clear_arena()
	else:
		_make_character_moving_move_one_step()





## OBJECT CLICKED EVENTS ##

func _character_selected_local(character):
	var damage_amout = 15
	var is_dead = character.current_health - damage_amout <= 0
	var damages_infos = [{'id character':character.id_character,
					'damage': damage_amout,
					'event': []}]
	if is_dead:
		damages_infos[0]['event'] += ['character dead']
	make_character_cast_spell(current_character, character.current_cell, damages_infos)
	

func _on_character_selected(character):
	if not state == 'cast_spell':
		current_character.unselect()
		# select character
		if teams[my_team_name].has_member(character):
			# The client can select only chracter in his own team
			current_character = character
			clear_arena()
			
	else:
		if not is_game_local:
			emit_signal('ask_cast_spell', current_character, character.current_cell) # for now there is only one spell
		
		else:
			# Game is local, we have to create a response like the server would do
			_character_selected_local(character)




func _on_cell_clicked(cell):
	if state == 'normal':
		if len(path_serialized) > 0 :
			if not is_game_local:
				emit_signal('ask_move', current_character, path_serialized)
			else:
				make_character_move_following_path_valid(current_character, path_serialized)
	elif state == 'cast_spell':
		if cell in fov:
			if not is_game_local:
				emit_signal('ask_cast_spell', current_character, cell) # for now there is only one spell
			else:
				var damages_infos = [] # hit a empty cell
				make_character_cast_spell(current_character, cell, damages_infos)






## OBJECT HOVERED EVENTS ##
func _on_cell_hovered(cell):
	if state == 'normal':
		clear_arena()
		path_serialized = $Map.display_path(current_character.current_cell, 
								cell, 
								current_character.current_range_displacement)
	
func _on_character_hovered(character):
	if state == 'normal':
		clear_arena()
		$Map.display_displacement_range(character.current_cell, 
										character.current_range_displacement)




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

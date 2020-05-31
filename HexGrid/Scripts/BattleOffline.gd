extends 'res://Scripts/Battle.gd'

func _ready():
	# Generate teams and map, then instanciate them
	# Called only when battlescreen is run with f6
	var teams_infos = get_teams_infos()
	$Map.generate_grid()
	init_battle($Map.grid, teams_infos)
	next_turn()


## BEHAVIOUR FOR ASK ACTIONS ##
func ask_end_turn(): 
	print('Turn end, new turn.')
	next_turn()


func ask_cast_spell(character, spell_name, cell):
	var target = cell.character_on
	var damages_infos = []
	
	if target != null:
		var damage_amout = 35
		var is_dead = target.current_health - damage_amout <= 0
		damages_infos = [{'id character': target.id_character,
						'damage': damage_amout,
						'event': []}]
		if is_dead:
			damages_infos[0]['event'] += ['character dead']
	make_character_cast_spell(character, cell, damages_infos)


func ask_move(character, path):
	make_character_move_following_path_valid(character, path)


# warning-ignore:unused_argument
func choose_next_current_team(data=null):
	var list_keys = teams.keys()
	var next_index = -1
	if current_team != null:
		next_index = (list_keys.find(current_team.name) + 1) % len(list_keys)
	else:
		next_index = 0
	current_team = teams[list_keys[next_index]]


# ------------------


func get_teams_infos():
	return {'Local redz': 
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

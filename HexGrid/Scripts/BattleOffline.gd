extends 'res://Scripts/Battle.gd'

var rng = RandomNumberGenerator.new()




func _ready():
	rng.randomize()
	# Generate teams and map, then instanciate them
	# Called only when battlescreen is run with f6
	var teams_infos = get_teams_infos()
	$Map.generate_grid()
	for t in teams_infos.values():
		for character in t['characters']:
			while $Map.grid[character['q']][character['r']] != 'floor':
				character['q'] += rng.randi_range(-1, 1) 
				character['r'] += rng.randi_range(-1, 1)
				while not $Map.grid.has(character['q']):
					character['q'] += rng.randi_range(-1, 1)
				while not $Map.grid[character['q']].has(character['r']):
					character['r'] += rng.randi_range(-1, 1)
			
			$Map.grid[character['q']][character['r']] = 'blocked'
	
	init_battle($Map.grid, teams_infos)
	next_turn()


## BEHAVIOUR FOR ASK ACTIONS ##
func ask_end_turn(): 
	print('Turn end, new turn.')
	next_turn()


func ask_cast_spell(character, spell_name, target_cell):
	# Turn and action already verified
	# In this function, damage_infos computation
	
	var damages_infos = []
	var damage_amount
	var target_character
	var info = {}
	var spell : Spell = character.Spells[spell_name]
	
	var touched_cells = $Map.get_impact(spell,\
										character.current_cell, \
										target_cell)
	
	for cell in touched_cells:
		if cell.has_character_on():
			info = {}
			target_character = cell.character_on
			
			damage_amount = rng.randi_range(spell.damage_amount[0], \
											spell.damage_amount[1])
			
			var is_dead = target_character.current_health - damage_amount <= 0
			info = {'id character': target_character.id_character,
					'damage'	: damage_amount,
					'events'	: [],
					'character'	: target_character
					}
			if is_dead:
				info['events'] += ['character dead']
			
			damages_infos.append(info)
			
	make_character_cast_spell(character, target_cell, spell_name, damages_infos)


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


func _unhandled_key_input(event):
	if event is InputEventKey and not event.pressed:
		var direction = Vector3.ZERO
		if event.scancode == KEY_Q :
			if event.shift:
				# move towards -Q
				direction = Vector3(-1,0,0)
			else:
				# move towards +Q
				direction = Vector3(1,0,0)
		elif event.scancode == KEY_R :
			if event.shift:
				# move towards -R
				direction = Vector3(0,-1,0)
			else:
				# move towards +R
				direction = Vector3(0,1,0)
		elif event.scancode == KEY_Z :
			if event.shift:
				# move towards -Z
				direction = Vector3(0,0,-1)
			else:
				# move towards +Z
				direction = Vector3(0,0,1)
		else:
			return
		$Map.add_step(test_path, direction)
		clear_arena()
		for c in test_path:
			c.change_material('green')
		
	get_tree().set_input_as_handled()

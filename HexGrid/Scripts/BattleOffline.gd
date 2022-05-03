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
	var spell : Spell = character.Spells[spell_name]
	
	var touched_cells = $Map.get_impact(spell,\
										character.current_cell, \
										target_cell)
	
	var caster_team = null
	for t in teams.values():
		if t.has_member(character):
			caster_team = t
			break
		
	damages_infos = spell.compute_damages_on(target_cell, \
											touched_cells, \
											caster_team)
			
	make_character_cast_spell(character, target_cell, spell_name, damages_infos)


func ask_move(character, path):
	make_character_move_following_path_valid(character, path)


# warning-ignore:unused_argument
func choose_next_current_team(data=null):
	var teams_id = teams.keys()
	
	# Default selected team
	var next_index = 0
	
	# If a team is already selected, select the following one
	if current_team != null:
		next_index = (teams_id.find(current_team.name) + 1) % len(teams_id)
	
	current_team = teams[teams_id[next_index]]

func get_character_team(character):
	for team in teams.values():
		if team.has_member(character):
			return team
	
	return null

func end_game(data=null):
	if data == null:
		return
	elif "team_name" in data.keys():
		$BattleControl.show_endgame_widget(data)
	else:
		return

# ------------------


func get_teams_infos():
	var default_health = 25
	return {'Local redz': 
						{	'user id': -1,
							'color': 'red',
							'characters': 
								[ {	'health':default_health, 
									'id character':1, 
									'q':0, 
									'r':0, 
									'range displacement':5, 
									'team_color':'red'
									},
								{	'health':default_health, 
									'id character':4, 
									'q':1, 
									'r':3, 
									'range displacement':5, 
									'team_color':'red'
									},
								{	'health':default_health, 
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
								[ {	'health':default_health, 
									'id character':0,
									'q':1, 
									'r':-5, 
									'range displacement':5, 
									'team_color':'blue'
									},
								{	'health':default_health, 
									'id character':2,
									'q':6, 
									'r':-5, 
									'range displacement':5, 
									'team_color':'blue'
									},
								{	'health':default_health, 
									'id character':3,
									'q':6, 
									'r':-4, 
									'range displacement':5, 
									'team_color':'blue'
									}
								]
						}
					}

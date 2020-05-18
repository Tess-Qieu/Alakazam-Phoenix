extends 'res://Scripts/Battle.gd'

func _ready():
	# Generate teams and map, then instanciate them
	# Called only when battlescreen is run with f6
	var teams_infos = get_teams_infos()
	$Map.generate_grid()
	.init_battle($Map.grid, teams_infos)
#	get_parent().get_node("EndTurn_Widget/Button").connect("pressed",self,"_on_button_pressed")


func ask_cast_spell(character, cell):
	var target = cell.character_on
	var damages_infos = []
	
	if target != null:
		var damage_amout = 15
		var is_dead = target.current_health - damage_amout <= 0
		damages_infos = [{'id character': target.id_character,
						'damage': damage_amout,
						'event': []}]
		if is_dead:
			damages_infos[0]['event'] += ['character dead']
			
	make_character_cast_spell(character, cell, damages_infos)



func ask_move(character, path):
	make_character_move_following_path_valid(character, path)








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

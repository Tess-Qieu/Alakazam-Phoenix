extends 'res://Scripts/Battle.gd'

func _ready():
	Network.set_server_receiver_node(self)

## COMMUCATION WITH SERVER
func send_data(data):
	# We add the game lobby id
	# We can add the state of the game too
	data['details']['lobby id'] = Global.lobby_id
	data['details']['user id'] = Global.user_id
	Network.send_data(data)
	
func _on_message(data):
	if not 'action' in data.keys():
		print("NetworkError: no key action in data")
		return
		
	elif data['action'] == 'player left':
		player_left(data)
		
	elif data['action'] == 'observator left':
		observator_left(data)
	
	elif data['action'] == 'game':
		# The game is running
		if 'response' in data.keys():
			# Response from the server
			if data['response'] == 'move':
				move_valid(data['details'])

			elif data['response'] == 'cast spell':
				cast_spell_valid(data['details'])

			elif data['response'] == 'not valid':
				print('Action ask not valid')

			else:
				print('NetworkError: response {0} not known.'.format([data['response']]))

		if 'directive' in data.keys():
			# directive from the server
			if data['directive'] == 'new turn':
				next_turn(data['details'])
			
			elif data['directive'] == 'begin turn':
				begin_turn(data)
	
	elif data['action'] == 'game over':
		game_over(data['details'])
		
	else :
		print("NetworkError: action {0} not known.".format([data['action']]))





## BEHAVIOUR FOR ASK ACTIONS ##
func ask_ready():
	var data = {'action' : 'new game', 'details' : {'ready' : true}}
	send_data(data)
	
func ask_end_turn(): 
	var data = {'action': 'game',
				'ask': 'end turn',
				'details': {}}

	send_data(data)

func ask_begin_turn():
	var data = {'action' : 'game',
				'ask'	 : 'begin turn',
				'details': {}}
	send_data(data)

func ask_move(character, path):
	var data = {'action': 'game',
				'ask': 'move', 
				'details': {'id character' : character.id_character,
							'path' : path,
							}}
	send_data(data)

func ask_cast_spell(thrower, spell_name, target): 
	# thrower is the character which casts the spell
	# target is the cell where the spell is casted
	var data = {'action': 'game',
				'ask': 'cast spell',
				'details': {'thrower': {'id character': thrower.id_character},
							'spell name': spell_name,
							'target': [target.q, target.r]
							}
				}
	send_data(data)



## BEHAVIOUR WHEN THE SERVER VALID AN ACTION ##
func choose_next_current_team(data=null):
	for team in teams.values():
		if team.user_id == data['user id']:
			current_team = team

func move_valid(data):
	var character = get_character_by_id(data['id character'])
	var path_valid = data['path']
	make_character_move_following_path_valid(character, path_valid)

func cast_spell_valid(data):
	var character_thrower = get_character_by_id(data['thrower']['id character'])
	var cell_target = get_cell_by_coords(data['target'][0], data['target'][1])
	var spell_name = data['spell name']
	var damages_infos = data['damages']
	for info in damages_infos:
		info['character'] = get_character_by_id(info['id character'])
	make_character_cast_spell(character_thrower, cell_target, spell_name, damages_infos)





## PLAYER/OBSERSATOR LEFT AND RETURN TO WAITING LOBBY##
func player_left(data):
	print('Player {0} left the game'.format([data['details']['user']]))
	destroy_battle_and_return_to_waitingLobby()

func observator_left(data):
	print('Observator {0} left the game'.format([data['details']['user']]))

func game_over(data):
	var victory = data['victory']
	if victory:
		print('Game over. You won !')
	else:
		print('Game over. You loose !')
	destroy_battle_and_return_to_waitingLobby()
	
func destroy_battle_and_return_to_waitingLobby():
	# Destroy the Battle, go back to WaitingLobby	
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(Global.WaitingLobby)
	self.queue_free()

extends 'res://Scripts/Battle.gd'

var is_my_turn = false
var memory_on_turn # memory of what action have been made by which character this turn


func _ready():
	Network.set_server_receiver_node(self)
	ask_ready() # TEMPORARY SOLUTION TO SAY READY, LATER THERE WILL BE A BUTTON

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
				new_turn(data['details'])
	
	elif data['action'] == 'game over':
		game_over(data['details'])
		
		
	else :
		print("NetworkError: action {0} not known.".format([data['action']]))





## BEHAVIOUR FOR ASK ACTIONS ##
func ask_ready():
	var data = {'action' : 'new game', 'details' : {'ready' : true}}
	send_data(data)
	
func ask_end_turn(): 
	## Request from the client to the server to end his turn before 
	#   the timer's end
	if not is_my_turn or state != 'normal':
		# Client should not ask to end his turn if it's not his turn to play
		#  of if the Battle is still busy
		return
#
	var data = {'action': 'game',
				'ask': 'end turn',
				'details': {}}

	send_data(data)

func ask_move(character, path):
	if not is_my_turn or memory_on_turn['move'][character]:
		# Client should not send ask for a play if it's not his turn to play
		# Or if the character has already move this turn
		return

	var data = {'action': 'game',
				'ask': 'move', 
				'details': {'id character' : character.id_character,
							'path' : path,
							}}
	send_data(data)

func ask_cast_spell(thrower, target): # for now, useless to precise which spell to use
	# thrower is the character which cast the spell
	# target is the cell where the spelle is cast
	if not is_my_turn or memory_on_turn['cast spell'][thrower]:
		# Client should not send ask for a play if it's not his turn to play
		# Or if the thrower has already cast a spell this turn
		return

	var data = {'action': 'game',
				'ask': 'cast spell',
				'details': {'thrower': {'id character': thrower.id_character},
							'target': [target.q, target.r]
							}
				}
	send_data(data)






## GAME ##
func new_turn(data):
	self._retrieve_game_infos(data)
	is_my_turn = data['user id'] == Global.user_id
	print('My turn : {0}'.format([is_my_turn]))
	$BattleControl/EndTurn_Widget.reset(is_my_turn, data['turn time'])

func move_valid(data):
	self._retrieve_game_infos(data)
	var character = get_character_by_id(data['id character'])
	var path_valid = data['path']
	make_character_move_following_path_valid(character, path_valid)

func cast_spell_valid(data):
	self._retrieve_game_infos(data)
	var character_thrower = get_character_by_id(data['thrower']['id character'])
	var cell_target = get_cell_by_coords(data['target'][0], data['target'][1])
	var damages_infos = data['damages']
	make_character_cast_spell(character_thrower, cell_target, damages_infos)





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
	


## USEFULL FUNCTIONS ##
func _retrieve_memory_on_turn(data):
	var old_memo = data['memory on turn']
	var new_memo = {}
	for action in old_memo:
		new_memo[action] = {}
		for character_id in old_memo[action].keys():
			var character = get_character_by_id(character_id)
			new_memo[action][character] = old_memo[action][character_id]
	memory_on_turn = new_memo
	
func _retrieve_game_infos(data):
	_retrieve_memory_on_turn(data)


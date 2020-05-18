extends 'res://Scripts/Battle.gd'


var lobby_id
var is_my_turn = false


func _ready():
	Network.set_server_receiver_node(self)
	Network.connect_to_server()
	

## COMMUCATION WITH SERVER
func send_data(data):
	# We add the game lobby id
	# We can add the state of the game too
	data['details']['lobby id'] = lobby_id
	data['details']['user id'] = Global.user_id
	Network.send_data(data)
	
func _on_message(data):
	if not 'action' in data.keys():
		print("NetworkError: no key action in data")
		return
		
	if data['action'] == 'connection':
		# Validation connection from server
		if 'user id' in data['details'].keys():
			Global.user_id = data['details']['user id']
			ask_to_play() # TEMPORARY SOLUTION TO LAUNCH A GAME, LATER THERE WILL BE A BUTTON
		else:
			print('NetworkError: no key accept in details for connection.')
	
	elif data['action'] == 'player left':
		player_left(data)
	
	elif data['action'] == 'observator left':
		observator_left(data)
	
	elif data['action'] == 'ask to wait':
		# The server is looking for a contestant
		# Nothing to do until next message from server
		pass
	
	elif data['action'] == 'new game':
		# New game, we go into Battle mode now
		new_game(data)
		ask_ready() # TEMPORARY SOLUTION TO SAY READY, LATER THERE WILL BE A BUTTON
		
	
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
		print('Game over.')
		get_tree().quit()
		
		
	else :
		print("NetworkError: action {0} not known.".format([data['action']]))





## BEHAVIOUR FOR ASK ACTIONS ##
func ask_to_play():
	var data = {'action' : 'ask to play', 'details' : {}} # put team infos here
	Network.send_data(data)

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
	if not is_my_turn :
		# Client should not send ask for a play if it's not his turn to play
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
	if not is_my_turn :
		# Client should not send ask for a play if it's not his turn to play
		return

	var data = {'action': 'game',
				'ask': 'cast spell',
				'details': {'thrower': {'id character': thrower.id_character},
							'target': [target.q, target.r]
							}
				}
	send_data(data)






## GAME ##
func new_game(data):
	# Init the new Battle	
	lobby_id = data['details']['lobby id']
	var grid_infos = data['details']['grid']
	var teams_infos = data['details']['teams']
	init_battle(grid_infos, teams_infos)

func new_turn(data):
	is_my_turn = data['user id'] == Global.user_id
	print('My turn : {0}'.format([is_my_turn]))
	$BattleControl/EndTurn_Widget.reset(is_my_turn, data['turn time'])

func move_valid(data):
	var character = get_character_by_id(data['id character'])
	var path_valid = data['path']
	make_character_move_following_path_valid(character, path_valid)

func cast_spell_valid(data):
	var character_thrower = get_character_by_id(data['thrower']['id character'])
	var cell_target = get_cell_by_coords(data['target'][0], data['target'][1])
	var damages_infos = data['damages']
	make_character_cast_spell(character_thrower, cell_target, damages_infos)





## PLAYER/OBSERSATOR LEFT##
func player_left(data): # NOT IMPLEMENTED YET
	# Destroy the Battle, go back to menu, ask to play
	print('Player {0} left the game'.format([data['details']['user']]))
	get_tree().quit()

#	Global.change_screen('WaitingScreen')
#	Global.change_server_receiver_node()

	# remove old battle, create a new one
#	get_battle().queue_free()
#	var new_battle = Battle.instance()
#	new_battle.set_name('Battle')
#	$BattleScreen.add_child(new_battle)
#
#	ask_to_play
	pass 

func observator_left(data): # NOT IMPLEMENTED YET
	print('Observator {0} left the game'.format([data['details']['user']]))

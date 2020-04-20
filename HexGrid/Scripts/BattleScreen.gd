extends Control

var Battle = preload("res://Scenes/Battle.tscn")

var lobby_id


## COMMUNICATION FUNCTIONS ##
func send_data(data):
	# We add the game lobby id
	# We can add the state of the game too
	data['details']['id'] = lobby_id
	Global.network.send_data(data)

func _on_message(data):
	if not 'action' in data.keys():
		print('NetworkError: no key action in data.')
		return
	
	if data['action'] == 'new game':
		new_game(data)
		
	elif data['action'] == 'player left':
		player_left(data)
		
	elif data['action'] == 'observator left':
		observator_left(data)
		
	elif data['action'] == 'game':
		# The game is running
		if data['response'] == 'move':
			move_valid(data['details'])
			
		elif data['response'] == 'not_valid':
			print('Movement not valid')
#		else:
#			print('NetworkError: response {0} not known.'.format(data['response'])
			
	else:
		print("NetworkError: action {0} not known.".format([data['action']]))


## ASK PLAY TO SERVER
func _on_ask_move(character, path):
	var path_serialized = []
	for c in path:
		path_serialized += [[c.q, c.r]]
		
	var data = {'action' : 'game',
				'ask' : 'move', 
				'details' : {'id_character' : character.id_character,
							'path' : path_serialized,
							}}
	send_data(data)



## GAME ##
func new_game(data):
	# Init the new Battle	
	lobby_id = data['details']['id']
	
	var grid = data['details']['grid']
	var team_blue = data['details']['team_blue']
	var team_red = data['details']['team_red']
	get_battle().init(grid, team_blue, team_red, self)
	
	data = {'action' : 'new game', 'details' : {'ready' : true}}
	send_data(data)

func move_valid(data):
	var character = get_character_by_id(data['id_character'])
	var path_valid = data['path']
	get_battle().make_character_move_following_path_valid(character, path_valid)





## PLAYER/OBSERSATOR LEFT##
func player_left(data):
	# Destroy the Battle, go back to menu, ask to play
	print('Player {0} left the game'.format([data['details']['user']]))
	
	Global.change_screen('WaitingScreen')
	Global.change_server_receiver_node()
	
	# remove old battle, create a new one
	get_battle().queue_free()
	var new_battle = Battle.instance()
	new_battle.set_name('Battle')
	add_child(new_battle)
	
	ask_to_play()

# /!\ temporary solution, later it will be prompt with a button on a menu
# /!\ duplicate the same function in Game.gd
func ask_to_play():
	var data = {'action' : 'ask to play', 'details' : {}} # put team infos here
	Global.network.send_data(data)

func observator_left(data):
	print('Observator {0} left the game'.format([data['details']['user']]))





## USEFULL FUNCTIONS ##
func get_battle():
	# Only solution to find the node Battle which change name
	for node in get_children():
		if 'Battle' in node.name:
			return node

func get_character_by_id(id_character):
	var battle = get_battle()
	for character in battle.team_red + battle.team_blue:
		if character.id_character == id_character:
			return character
	return null

extends Control

var Battle = preload("res://Scenes/Battle.tscn")

var lobby_id


## USEFULL FUNCTIONS ##
func get_battle():
	# Only solution to find the node Battle which change name
	for node in get_children():
		if 'Battle' in node.name:
			return node


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
		
	else :
		print("NetworkError: action {0} not known.".format([data['action']]))



## NEW GAME ##
func new_game(data):
	# Init the new Battle	
	lobby_id = data['details']['id']
	var grid = transform_grid_keys(data['details']['grid'])
	var team_blue = data['details']['team_blue']
	var team_red = data['details']['team_red']
		
	get_battle().init(grid, team_blue, team_red, self)
	
	data = {'action' : 'new game', 'details' : {'ready' : true}}
	send_data(data)

func transform_grid_keys(grid):
	var new_grid = {}
	for q in grid.keys():
		new_grid[int(q)] = {}
		for r in grid[q].keys():
			new_grid[int(q)][int(r)] = grid[q][r]
	return new_grid


## ASK PLAY TO SERVER
func _on_ask_move(character, cell):
	var data = {}
	pass





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
func ask_to_play():
	var data = {'action' : 'ask to play', 'details' : {}} # put team infos here
	Global.network.send_data(data)

func observator_left(data):
	print('Observator {0} left the game'.format([data['details']['user']]))

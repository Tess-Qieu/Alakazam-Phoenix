extends Control


func _ready():
	Network.set_server_receiver_node(self)
	if not Network.is_connected:
		Network.connect_to_server()
	else:
		ask_to_play()

## COMMUCATION WITH SERVER
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
	
	elif data['action'] == 'ask to wait':
		# The server is looking for a contestant
		# Nothing to do until next message from server
		pass
		
	elif data['action'] == 'new game':
		# New game, we go into Battle mode now
		new_game(data)
		

## BEHAVIOUR FOR ASK ACTIONS ##
func ask_to_play():
	var data = {'action' : 'ask to play', 'details' : {}} # put team infos here
	Network.send_data(data)

func new_game(data):
	# Init the new Battle	
	var lobby_id = data['details']['lobby id']
	var grid_infos = data['details']['grid']
	var teams_infos = data['details']['teams']
	
	Global.lobby_id = lobby_id
	
	var battleOnline = Global.BattleOnline.instance()
	get_parent().add_child(battleOnline)
	battleOnline.init_battle(grid_infos, teams_infos)
	
	# warning-ignore:return_value_discarded	
	get_tree().change_scene_to(battleOnline)

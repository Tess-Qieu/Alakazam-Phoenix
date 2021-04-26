extends Control

# Memorization of the Battle
var battleOnline

func _ready():
	Network.set_server_receiver_node(self)
	
	$VBoxContainer/Label.text = "Connection to server"
	if not Network.is_connected:
		Network.connect_to_server()

## COMMUCATION WITH SERVER
func _on_message(data):
	if not 'action' in data.keys():
		print("NetworkError: no key 'action' in data")
		return
	
	if data['action'] == 'connection':
		# Valid connection from server
		if 'user id' in data['details'].keys():
			Global.user_id = data['details']['user id']
			
			# GUI status update
			$VBoxContainer/Label.text = "Connected to server\n"
			
			# Signal connection and button show
			$VBoxContainer/Button.connect("pressed", self, "ask_to_play")
			$VBoxContainer/Button.text = "Ask to play"
			$VBoxContainer/Button.show()
			
		else:
			$VBoxContainer/Label.text = "Key error."
			print('NetworkError: no acceptable key found in connection details.')
	
	elif data['action'] == 'ask to wait':
		# The server is looking for an opponent
		# GUI status update
		$VBoxContainer/Label.text = "Waiting for an opponent\n"
		
		# Button disabling
		$VBoxContainer/Button.disabled = true
		
	elif data['action'] == 'new game':
		# GUI status update
		$VBoxContainer/Label.text = "Initializing the battlefield\n"
		$VBoxContainer/Button.hide()
		
		# New game, we go into Battle mode now
		new_game(data)
	
	elif data['action'] == 'game':
		# Change displayed scene to battleOnline
		get_parent().add_child(battleOnline)
		
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(battleOnline)
		battleOnline._on_message(data)

## BEHAVIOUR FOR ASK ACTIONS ##
func ask_to_play():
	var data = {'action' : 'ask to play', 'details' : {}} # put team infos here
	Network.send_data(data)

func new_game(data):
	# Gather information from server
	var lobby_id = data['details']['lobby id']
	var grid_infos = data['details']['grid']
	var teams_infos = data['details']['teams']
	
	Global.lobby_id = lobby_id
	
	# Battle initialization
	battleOnline = Global.BattleOnline.instance()
	battleOnline.init_battle(grid_infos, teams_infos)
	
	# GUI status update
	$VBoxContainer/Label.text = "Waiting for the opponent\n"

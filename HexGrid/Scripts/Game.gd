extends Control


var pseudo = ''


func _ready():
	Global.init_game()
	$BattleNetwork/BattleScreen.visible = false
	$WaitingScreen.visible = true
	
	pseudo = 'Naowak'
	
	$Network.connect_to_server()
	


## COMMUCATION WITH SERVER
func _on_message(data):
	if not 'action' in data.keys():
		print("NetworkError: no key action in data")
		return
		
		
	if data['action'] == 'connection':
		# Validation connection from server
		if 'accept' in data['details'].keys():
			if data['details']['accept'] == true:
				ask_to_play()
		else:
			print('NetworkError: no key accept in details for connection.')
		
	elif data['action'] == 'ask to wait':
		# The server is looking for a contestant
		# Nothing to do until next message from server
		pass
	
	elif data['action'] == 'new game':
		# New game, we go into Battle mode now
		Global.change_screen('BattleNetwork/BattleScreen')
		Global.change_server_receiver_node('BattleNetwork')
		Global.server_receiver_node._on_message(data)
		
	else :
		print("NetworkError: action {0} not known.".format([data['action']]))



func ask_to_play():
	var data = {'action' : 'ask to play', 'details' : {}} # put team infos here
	Global.network.send_data(data)





## INIT CONNECTIONS WITH THE SERVER ##
func _on_connection_to_server():
	# called when the connection have been made
	_identify_to_server()

func _identify_to_server():
	var data = {'action' : 'connection', 'details' : {'pseudo' : pseudo}}
	Global.network.send_data(data)




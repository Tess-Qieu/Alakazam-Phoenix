extends Control


var pseudo = ''


func _ready():
	$BattleScreen.visible = false
	$WaitingScreen.visible = true
	
	pseudo = 'Naowak'
	
	$Network.connect_to_server()




## COMMUNICATION WITH SERVER ##
func _on_connection_to_server():
	# called when the connection have been made
	_identify_to_server()

func _identify_to_server():
	var data = {'action' : 'connection', 'details' : {'pseudo' : pseudo}}
	Global.network.send_data(data)


func ask_to_play():
	var data = {'action' : 'ask to play', 'details' : {}} # put team infos here
	Global.network.send_data(data)
	
	
	
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
		pass
	
	elif data['action'] == 'new game':
		# Nouvelle game, on bascule dans BattleScreen
		Global.change_screen('BattleScreen')
		Global.change_server_receiver_node('BattleScreen')
		Global.server_receiver_node._on_message(data)
		
	else :
		print("NetworkError: action {0} not known.".format([data['action']]))






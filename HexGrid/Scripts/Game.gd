extends Control


var screen = "WaitingScreen" # Scene to show
var server_receiver_node = self # Node where information from server is throwed to

var pseudo = ''


func _ready():
	$BattleScreen.visible = false
	$WaitingScreen.visible = true
	
	pseudo = 'Naowak'
	
	$Network.connect_to_server()




## MANAGEMENT ##
func change_screen(new_screen):
	if screen != new_screen :
		var ns = get_tree().get_root().get_node("Game/" + new_screen)
		var os = get_tree().get_root().get_node("Game/" + screen)
		os.visible = false
		ns.visible = true
		screen = new_screen

func change_server_receiver_node(new_receiver) :
	var nr = get_tree().get_root().get_node("Game/" + new_receiver)
	server_receiver_node = nr





## COMMUNICATION WITH SERVER ##
func _on_connection_to_server():
	# called when the connection have been made
	identify_to_server()

func identify_to_server():
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
		change_screen('BattleScreen')
		change_server_receiver_node('BattleScreen')
		server_receiver_node._on_message(data)
		
	else :
		print("NetworkError: action {} not known.".format([data['action']]))






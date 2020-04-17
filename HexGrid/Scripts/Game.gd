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
#	Global.network.send_data(data)
	
func _on_message(_data):
	pass






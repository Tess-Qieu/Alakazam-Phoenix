extends Control


# Scene to show
var screen = "WaitingScreen"
# Node which information from server is throwed to
var server_receiver_node = self


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
	

func _on_message(data):
	pass


func _ready():
	$BattleScreen.visible = false
	$WaitingScreen.visible = true
	
	$Network.connect_to_server('Naowak')

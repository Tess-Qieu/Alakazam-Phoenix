extends Node

var materials = {'hole': 'ae8257', 
				'floor': "e6cab8", 
				'full': '352f2b',
				'border': '352f2b',
				'blue': '2876df',
				'red': 'df4828',
				'green': '79cc2b',
				'skyblue': '87ceeb',
				'grey': 'c6beba'
				} 

var network = null
var server_receiver_node = null # Node where information from server is throwed to
var screen = null # Scene to show

var pseudo = ''
var user_id = -1


func _ready():
	_init_materials()	

func _init_materials():
	for key in materials.keys():
		var color = materials[key]
		var mat = SpatialMaterial.new()
		mat.albedo_color = Color(color)
		materials[key] = mat

func _set_network():
	network = get_tree().get_root().get_node('Game/Network')
	server_receiver_node = get_tree().get_root().get_node('Game')
	
func init_game():
	_set_network()
	screen = 'WaitingScreen'
	pseudo = 'Naowak'
	
## MANAGEMENT ##
#func find_node(node_parent, node_name):
#	var nodes = node_name.split('/')
#	for node in node_parent.get_children():
#		if node_name in node.name:
#			return node

func change_screen(new_screen=''):
	if screen != new_screen :
		var ns = get_tree().get_root().get_node("Game/" + new_screen)
		var os = get_tree().get_root().get_node("Game/" + screen)
		os.visible = false
		ns.visible = true
		screen = new_screen

func change_server_receiver_node(new_receiver='') :
	var nr = get_tree().get_root().get_node("Game/" + new_receiver)
	server_receiver_node = nr

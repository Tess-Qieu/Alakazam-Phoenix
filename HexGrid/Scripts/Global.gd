extends Node

var materials = {'hole': 'ae8257', 
				'floor': "e6cab8", 
				'full': '352f2b',
				'border': '352f2b',
				'white' : 'ffffff',
				'blue': '2876df',
				'red': 'df4828',
				'green': '79cc2b',
				'skyblue': '87ceeb',
				'grey': 'c6beba'
				} 


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

	
## MANAGEMENT ##
func change_screen(new_screen=''):
	if screen != new_screen :
		var ns = get_tree().get_root().get_node("Game/" + new_screen)
		var os = get_tree().get_root().get_node("Game/" + screen)
		os.visible = false
		ns.visible = true
		screen = new_screen

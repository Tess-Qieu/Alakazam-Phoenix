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



func _ready():
	_init_materials()
	_set_network()

func _init_materials():
	for key in materials.keys():
		var color = materials[key]
		var mat = SpatialMaterial.new()
		mat.albedo_color = Color(color)
		materials[key] = mat

func _set_network():
	network = get_tree().get_root().get_node('Game/Network')

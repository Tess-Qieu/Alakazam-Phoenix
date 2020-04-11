extends Node

var materials = {'hole': 'ae8257', 
				'floor': "e6cab8", 
				'full': '352f2b',
				'border': '352f2b',
				'clicked_lmb': 'df4828', #lmb = Left Mouse Button
				'clicked_rmb': '60d1d9', #rmb = Right Mouse Button
				'path': '74e080'
				} 

func _ready():
	init_materials()

func init_materials():
	for key in materials.keys():
		var color = materials[key]
		var mat = SpatialMaterial.new()
		mat.albedo_color = Color(color)
		materials[key] = mat

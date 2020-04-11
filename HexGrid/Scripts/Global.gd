extends Node

var materials = {'hole': 'ae8257', 
				'floor': "e6cab8", 
				'full': '352f2b',
				'border': '352f2b',
				'clicked': 'df4828',
				'team_blue': '2876df'}

func _ready():
	init_materials()

func init_materials():
	for key in materials.keys():
		var color = materials[key]
		var mat = SpatialMaterial.new()
		mat.albedo_color = Color(color)
		materials[key] = mat

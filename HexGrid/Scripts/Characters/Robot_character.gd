extends 'res://Scripts/Characters/Character.gd'

func _ready():
	speed = 150
	
	# Miniature update
	miniature = load("res://Prefabs/Character/Robot_miniature.png")


func change_material(material_key: String):
	$Armature/TorsoBoneAttachment/BodyTorso.set_surface_material(0, Global.materials[material_key])

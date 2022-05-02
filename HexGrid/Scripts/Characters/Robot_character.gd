extends 'res://Scripts/Characters/Character.gd'

var color1 = 'fab45a' #yellow
var color2 = '646464'   #grey

func _ready():
	# Miniature update
	miniature = load("res://Prefabs/Character/Robot_miniature.png")
	
func change_material(material_key: String):
	$Armature/TorsoBoneAttachment/BodyTorso.set_surface_material(0, Global.materials[material_key])
#	$Armature/AntennaLBoneAttachment/Antenna_L.set_surface_material(0, Global.materials[material_key])
#	$Armature/AntennaRBoneAttachment/Antenna_R.set_surface_material(0, Global.materials[material_key])

extends 'res://Scripts/Characters/Character.gd'


func _ready():
	speed = 150


func change_material(material_key: String):
	$Armature/TorsoBoneAttachment/BodyTorso.set_surface_material(0, Global.materials[material_key])

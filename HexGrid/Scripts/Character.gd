extends KinematicBody
class_name Character

var my_team : Team


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func change_material(material_key):
	$MeshInstance.set_surface_material(0, Global.materials[material_key])

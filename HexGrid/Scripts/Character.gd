extends Spatial

signal character_selected

var current_cell

func init(cell, team):
	translation.x = cell.translation.x
	translation.y = 1.5
	translation.z = cell.translation.z
	current_cell = cell
	change_material(team)
	
func change_material(material_key):
	$KinematicBody/MeshInstance.set_surface_material(0, Global.materials[material_key])

func _on_KinematicBody_input_event(camera, event, click_position, click_normal, shape_idx):
	emit_signal("character_selected")

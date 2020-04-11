extends Spatial

var current_cell

func init(cell):
	translation.x = cell.translation.x
	translation.y = 1.5
	translation.z = cell.translation.z
	current_cell = cell
	change_material(Global.materials['team_blue'])
	
func change_material(material):
	$KinematicBody/MeshInstance.set_surface_material(0, material)



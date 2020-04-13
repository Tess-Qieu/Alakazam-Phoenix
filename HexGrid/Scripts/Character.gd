extends Spatial

signal character_selected

var Spell = preload("res://Scenes/Spell.tscn")

var current_cell
var casting


func init(cell, team):
	translation.x = cell.translation.x
	translation.y = 1.5
	translation.z = cell.translation.z
	current_cell = cell
	change_material(team)
	casting = false
	
func cast_spell(target):
	var to_look = target.translation
	to_look.y = translation.y
	look_at(to_look, Vector3(0, 1, 0))
	
	var spell = Spell.instance()
	spell.cast(current_cell, target)
	get_parent().add_child(spell)
	
func teleport_to(cell):
	current_cell = cell
	translation.x = cell.translation.x
	translation.z = cell.translation.z
	
	
func change_material(material_key):
	$MeshInstance.set_surface_material(0, Global.materials[material_key])


func _on_Character_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	# If the event is a mouse click
	if event is InputEventMouseButton and event.pressed:
		# A different material is applied on each button
		if event.button_index == BUTTON_LEFT :
			emit_signal("character_selected")
			
		elif event.button_index == BUTTON_RIGHT:
			pass

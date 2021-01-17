extends Spatial

signal cell_clicked

var q
var r
var kind
var character_on setget set_character

const CIRCLE_RAY = 1
const SPACE_BETWEEN = 0
const DIST = sqrt(3)*CIRCLE_RAY
const RATIO = (DIST + SPACE_BETWEEN)/DIST

const TRANS_RIGHT = Vector2(DIST*RATIO, 0)
const TRANS_DOWNRIGHT = Vector2(DIST*RATIO/2, 3.0*CIRCLE_RAY*RATIO/2)

## GENERAL SECTION ##
func _ready():
	pass

func init(_q, _r, _kind, battle_scene):
	q = _q
	r = _r
	kind = _kind
	character_on = null
	
	translation.x = q * TRANS_RIGHT.x + r * TRANS_DOWNRIGHT.x
	translation.z = r * TRANS_DOWNRIGHT.y
	change_material(kind)
	
	if battle_scene != null and kind == 'floor':
		# warning-ignore:return_value_discarded
		$Circle/Area.connect("mouse_entered", battle_scene, "_on_cell_hovered", [self])
		# warning-ignore:return_value_discarded
		connect("cell_clicked", battle_scene, "_on_cell_clicked", [self])

func show_coordinates(showing):
	if kind in ["floor","blocked"]:
		if showing:
			$Label3D/Viewport/Control/Panel/Label.text = get_coords_string()
			$Label3D.show()
		else:
			$Label3D.hide()

func change_material(material_key):
	if material_key == 'blocked':
		material_key = 'floor'
	$Circle.set_surface_material(0, Global.materials[material_key])

func set_character(new_character):
	character_on = new_character
	
	if new_character != null:
		kind = 'blocked'
	else:
		kind = 'floor'

func get_coord_vect3():
	return Vector3(q, r, -q-r)

func has_character_on():
	return character_on != null

func get_coords_string():
	return "({0};{1})".format([q,r])


## EVENT HANDLING SECTION ##
func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	# If the event is a mouse click
	if event is InputEventMouseButton and event.pressed:
		if kind == "floor" :
			# A different material is applied on each button
			if event.button_index == BUTTON_LEFT :
				emit_signal('cell_clicked')
				
			elif event.button_index == BUTTON_RIGHT:
				pass
				
			elif event.button_index == BUTTON_MIDDLE:
				print("({0},{1})".format([q, r]))

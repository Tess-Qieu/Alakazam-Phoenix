extends Spatial

var q
var r
var kind

# Array of materials
# 0 = unselected
# 1 = selected_LMB
# 2 = selected_RMB
var materials = []

signal selected(index)

const CIRCLE_RAY = 1
const SPACE_BETWEEN = 0
const DIST = sqrt(3)*CIRCLE_RAY
const RATIO = (DIST + SPACE_BETWEEN)/DIST

const TRANS_RIGHT = Vector2(DIST*RATIO, 0)
const TRANS_DOWNRIGHT = Vector2(DIST*RATIO/2, 3.0*CIRCLE_RAY*RATIO/2)

const color_kind = {'hole': 'ae8257', 'floor': "e6cab8", 'full': '352f2b', \
	'border':'352f2b'}#, 'selected_0':'ffc752', 'selected_1':'60d1d9'}
	
func _ready():
	pass

func init(_q, _r, _kind):
	q = _q
	r = _r
	kind = _kind
	translation.x = q * TRANS_RIGHT.x + r * TRANS_DOWNRIGHT.x
	translation.z = r * TRANS_DOWNRIGHT.y
	change_color(color_kind[kind])
	
	# Save of default material
	materials.append($Circle.get_surface_material(0))
	# Addition of two materials corresponding to a selection
	materials.append(load("res://Prefabs/Cell/selected_mat.tres"))
	materials.append(load("res://Prefabs/Cell/selected_mat_2.tres"))

func change_color(color):
	var material = $Circle.get_surface_material(0)
	material.albedo_color = color
#	$Circle.set_surface_material(0, material)

func unselect():
	$Circle.set_surface_material(0, materials[0])

func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	# If the event is a mouse click
	if event is InputEventMouseButton and event.pressed:
		if kind == "floor" :
			print('Cell {0} / {1} : {2} !'.format([q, r, kind]))
			# A different material is applied on each button
			if event.button_index == BUTTON_LEFT :
				$Circle.set_surface_material(0, materials[1])
				emit_signal("selected", 0)
			elif event.button_index == BUTTON_RIGHT:
				$Circle.set_surface_material(0, materials[2])
				emit_signal("selected", 1)
	
	elif event is InputEventMouseMotion:
#		print('Cell {0} / {1} motionned !'.format([q, r]))
		pass
		

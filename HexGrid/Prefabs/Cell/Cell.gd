extends Spatial

var q
var r
var kind

# Array of materials
# 0 = unselected
# 1 = selected
var materials = []

signal selected(index)

const CIRCLE_RAY = 1
const SPACE_BETWEEN = 0
const DIST = sqrt(3)*CIRCLE_RAY
const RATIO = (DIST + SPACE_BETWEEN)/DIST

const TRANS_RIGHT = [DIST*RATIO, 0]
const TRANS_DOWNRIGHT = [DIST*RATIO/2, 3.0*CIRCLE_RAY*RATIO/2]

func _ready():
	pass

func init(_q, _r, _kind, _height):
	q = _q
	r = _r
	kind = _kind
	
	translation.x = q * TRANS_RIGHT[0] + r * TRANS_DOWNRIGHT[0]
	translation.y = _height * 0.5
	translation.z = r * TRANS_DOWNRIGHT[1]
	
	materials.append(load("res://Prefabs/Cell/Cell_White/Faces.material"))
	materials.append(load("res://Prefabs/Cell/selected_mat.tres"))

# Function allowing to unselect a tile
func unselect():
	$Circle.set_surface_material(0, materials[0])


func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			print('Cell {0} / {1} clicked !'.format([q, r]))
			if kind == "floor":
				$Circle.set_surface_material(0, materials[1])
				emit_signal("selected", 0)
	
	elif event is InputEventMouseMotion:
#		print('Cell {0} / {1} motionned !'.format([q, r]))
		pass
		

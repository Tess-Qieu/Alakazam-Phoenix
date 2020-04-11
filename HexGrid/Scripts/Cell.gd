extends Spatial

var q
var r
var kind
var origin_material

# Array of materials
# 0 = unselected
# 1 = selected_LMB
# 2 = selected_RMB
# 3 = path
var materials = []

signal selected(index)

const CIRCLE_RAY = 1
const SPACE_BETWEEN = 0
const DIST = sqrt(3)*CIRCLE_RAY
const RATIO = (DIST + SPACE_BETWEEN)/DIST

const TRANS_RIGHT = Vector2(DIST*RATIO, 0)
const TRANS_DOWNRIGHT = Vector2(DIST*RATIO/2, 3.0*CIRCLE_RAY*RATIO/2)

func _ready():
	pass

func init(q, r, kind):
	self.q = q
	self.r = r
	self.kind = kind
	translation.x = q * TRANS_RIGHT.x + r * TRANS_DOWNRIGHT.x
	translation.z = r * TRANS_DOWNRIGHT.y
	change_material(Global.materials[kind])
	
	# Save of default material
	materials.append($Circle.get_surface_material(0))
	# Addition of two materials corresponding to a selection
	materials.append(load("res://Prefabs/Cell/selected_mat.tres"))
	materials.append(load("res://Prefabs/Cell/selected_mat_2.tres"))
	materials.append(load("res://Prefabs/Cell/path_material.tres"))

func change_material(material):
	$Circle.set_surface_material(0, material)

func unselect():
	$Circle.set_surface_material(0, materials[0])
	
func color_path():
	$Circle.set_surface_material(0, materials[3])

func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	# If the event is a mouse click
	if event is InputEventMouseButton and event.pressed:
		if kind == "floor" :
			print('Cell {0} / {1} : {2} !'.format([q, r, kind]))
			# A different material is applied on each button
			if event.button_index == BUTTON_LEFT :
				# cell clicked
				change_material(Global.materials['clicked'])
				emit_signal("selected", 0)
			elif event.button_index == BUTTON_RIGHT:
				$Circle.set_surface_material(0, materials[2])
				emit_signal("selected", 1)
	
	elif event is InputEventMouseMotion:
#		print('Cell {0} / {1} motionned !'.format([q, r]))
		pass

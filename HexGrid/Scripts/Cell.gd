extends Spatial

var q
var r
var kind

signal selected(index)

const CIRCLE_RAY = 1
const SPACE_BETWEEN = 0
const DIST = sqrt(3)*CIRCLE_RAY
const RATIO = (DIST + SPACE_BETWEEN)/DIST

const TRANS_RIGHT = Vector2(DIST*RATIO, 0)
const TRANS_DOWNRIGHT = Vector2(DIST*RATIO/2, 3.0*CIRCLE_RAY*RATIO/2)

func _ready():
	pass

func init(_q, _r, _kind):
	q = _q
	r = _r
	kind = _kind
	translation.x = q * TRANS_RIGHT.x + r * TRANS_DOWNRIGHT.x
	translation.z = r * TRANS_DOWNRIGHT.y
	change_material(Global.materials[kind])

func change_material(material):
	$Circle.set_surface_material(0, material)

func unselect():
	$Circle.set_surface_material(0, Global.materials[kind])


func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	# If the event is a mouse click
	if event is InputEventMouseButton and event.pressed:
		if kind == "floor" :
			# A different material is applied on each button
			if event.button_index == BUTTON_LEFT :
				# cell clicked
				change_material(Global.materials['clicked_lmb'])
				emit_signal("selected", 0)
			elif event.button_index == BUTTON_RIGHT:
				change_material(Global.materials['clicked_rmb'])
				emit_signal("selected", 1)
	
	elif event is InputEventMouseMotion:
#		print('Cell {0} / {1} motionned !'.format([q, r]))
		pass

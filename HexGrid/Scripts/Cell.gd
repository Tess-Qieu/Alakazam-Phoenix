extends Spatial

var q
var r
var kind

signal cell_clicked(index)
signal cell_hovered(active)

const CIRCLE_RAY = 1
const SPACE_BETWEEN = 0
const DIST = sqrt(3)*CIRCLE_RAY
const RATIO = (DIST + SPACE_BETWEEN)/DIST

const TRANS_RIGHT = Vector2(DIST*RATIO, 0)
const TRANS_DOWNRIGHT = Vector2(DIST*RATIO/2, 3.0*CIRCLE_RAY*RATIO/2)

func _ready():
	$Circle/Area.connect("mouse_entered", self, '_on_Area_mouse_entered')
	$Circle/Area.connect("mouse_exited", self, '_on_Area_mouse_exited')
	pass

func init(_q, _r, _kind):
	q = _q
	r = _r
	kind = _kind
	translation.x = q * TRANS_RIGHT.x + r * TRANS_DOWNRIGHT.x
	translation.z = r * TRANS_DOWNRIGHT.y
	change_material(kind)

func change_material(material_key):
	$Circle.set_surface_material(0, Global.materials[material_key])

func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	# If the event is a mouse click
	if event is InputEventMouseButton and event.pressed:
		if kind == "floor" :
			# A different material is applied on each button
			if event.button_index == BUTTON_LEFT :
				emit_signal('cell_clicked',1)
				pass
				
			elif event.button_index == BUTTON_RIGHT:
#				emit_signal('cell_clicked', 1)
				pass
				
			elif event.button_index == BUTTON_MIDDLE:
				emit_signal('cell_clicked', 2)
				
	elif event is InputEventMouseMotion:
		pass

func _on_Area_mouse_entered():
	emit_signal("cell_hovered", true)

func _on_Area_mouse_exited():
	emit_signal("cell_hovered", false)

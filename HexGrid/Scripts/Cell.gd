extends Spatial

var q
var r
var kind
var origin_material

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

func change_material(material):
	$Circle.set_surface_material(0, material)

func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	# Catch click & motion events on cell
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			# cell clicked
			change_material(Global.materials['clicked'])
	
	elif event is InputEventMouseMotion:
#		print('Cell {0} / {1} motionned !'.format([q, r]))
		pass
		

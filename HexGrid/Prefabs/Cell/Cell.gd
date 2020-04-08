extends Spatial

var q
var r
var kind

const CIRCLE_RAY = 1
const SPACE_BETWEEN = 0
const DIST = sqrt(3)*CIRCLE_RAY
const RATIO = (DIST + SPACE_BETWEEN)/DIST

const TRANS_RIGHT = Vector2(DIST*RATIO, 0)
const TRANS_DOWNRIGHT = Vector2(DIST*RATIO/2, 3.0*CIRCLE_RAY*RATIO/2)

func _ready():
	pass 

func init(_q, _r, _kind, _height):
	q = _q
	r = _r
	kind = _kind
	
	translation.x = q * TRANS_RIGHT.x + r * TRANS_DOWNRIGHT.x
	translation.y = _height * 0.5
	translation.z = r * TRANS_DOWNRIGHT.y


func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
#			print('Cell {0} / {1} clicked !'.format([q, r]))
			pass
	
	elif event is InputEventMouseMotion:
#		print('Cell {0} / {1} motionned !'.format([q, r]))
		pass
		

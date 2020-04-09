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

const color_kind = {'hole': 'ae8257', 'floor': "e6cab8", 'full': '352f2b', \
	'border':'352f2b'}

func _ready():
	pass 

func init(_q, _r, _kind):
	q = _q
	r = _r
	kind = _kind
	translation.x = q * TRANS_RIGHT.x + r * TRANS_DOWNRIGHT.x
	translation.z = r * TRANS_DOWNRIGHT.y
	change_color(color_kind[kind])

func change_color(color):
	var material = $Circle.get_surface_material(0)
	material.albedo_color = color
	$Circle.set_surface_material(0, material)

func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	# Catch click & motion events on cell
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			# cell clicked
			if kind == 'floor':
				print('Cell {0} / {1} clicked !'.format([q, r]))
	
	elif event is InputEventMouseMotion:
#		print('Cell {0} / {1} motionned !'.format([q, r]))
		pass
		

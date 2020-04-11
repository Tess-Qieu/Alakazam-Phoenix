extends Spatial

# Basic info
var kind
# Axial coordinates
var q
var r

# Cube coordinates
var x
var y
var z

# Odd-r coordinates
var col
var row

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
	compute_cube_coordinates()
	compute_oddr_coordinates()
	
func compute_cube_coordinates():
	x = q
	z = r
	y = -x-z
	
func compute_oddr_coordinates():
	col = x + (z - (z&1)) / 2
	row = z

func change_material(material):
	$Circle.set_surface_material(0, material)

func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	# Catch click & motion events on cell
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			# cell clicked
			change_material(Global.materials['clicked'])
			print(col, '/', row)
	
	elif event is InputEventMouseMotion:
		pass
		

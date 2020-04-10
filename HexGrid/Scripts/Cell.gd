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

func init(q, r, kind, material):
	self.q = q
	self.r = r
	self.kind = kind
	self.origin_material = material
	translation.x = q * TRANS_RIGHT.x + r * TRANS_DOWNRIGHT.x
	translation.z = r * TRANS_DOWNRIGHT.y
	change_material(material)

func change_material(material):
	$Circle.set_surface_material(0, material)

func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	# Catch click & motion events on cell
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			# cell clicked
			var mat = SpatialMaterial.new()
			mat.albedo_color = Color(1, 0, 0)
			change_material(mat)
	
	elif event is InputEventMouseMotion:
#		print('Cell {0} / {1} motionned !'.format([q, r]))
		pass
		

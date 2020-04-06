extends Spatial

var q
var r
var kind

const CIRCLE_RAY = 1
const SPACE_BETWEEN = 0.05
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

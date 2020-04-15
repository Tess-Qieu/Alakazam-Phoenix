extends KinematicBody

export var speed = 10

export var dammage_amount = 15

var is_casting = false
var vect = Vector3(0, 0, 0)
var distance_to_make = 0
var distance_traveled = 0

func euclidean_dist(vec):
	return sqrt(pow(vec.x, 2) + pow(vec.z, 2))

func cast(thrower, target):
	# Translate the ball in front of the character
	# and prepare the throw
	translation.x = thrower.translation.x
	translation.y = 2
	translation.z = thrower.translation.z
	
	vect = target.translation - thrower.translation
	distance_to_make = euclidean_dist(vect)
	vect = vect / distance_to_make
	
	translation += 1*vect
	distance_traveled += 1.5*euclidean_dist(vect)
	
	is_casting = true
	
func _physics_process(delta):
	if is_casting:
		# Move the ball until it reaches a point or a body
		var rel_vec = vect * speed * delta
		var collision = move_and_collide(rel_vec)
		var dist = euclidean_dist(rel_vec)
		distance_traveled += dist
		
		if collision != null or distance_traveled >= distance_to_make:
			is_casting = false
			visible = false
			queue_free()
		
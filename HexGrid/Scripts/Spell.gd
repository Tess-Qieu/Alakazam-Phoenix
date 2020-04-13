extends Spatial

var is_casting = false
var vect = Vector3(0, 0, 0)
var speed = 10

func cast(thrower, target):
	translation.x = thrower.translation.x
	translation.y = 2
	translation.z = thrower.translation.z
	
	vect = target.translation - thrower.translation
	var dist = sqrt(pow(vect.x, 2) + pow(vect.z, 2))
	vect = vect / dist
	translation += 1.5*vect
	
	is_casting = true
	
func _physics_process(delta):
	if is_casting:
		var collision = $KinematicBody.move_and_collide(vect * delta * speed)
		if collision != null:
			is_casting = false
			visible = false

extends Spatial

var is_casting = false
var vect = Vector3(0, 0, 0)

func cast(thrower, target):
	translate_object_local(Vector3(0, 0, -2))
	vect.x = target.translation.x - thrower.translation.x
	vect.z = target.translation.z - thrower.translation.z
	is_casting = true
	
func _physics_process(delta):
	if is_casting:
		var collision = $KinematicBody.move_and_collide(vect * delta)
		if collision != null:
			is_casting = false
			print(collision)
			

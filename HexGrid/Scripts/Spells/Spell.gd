extends KinematicBody
class_name Spell

export var speed = 10

var is_casting = false
var vect = Vector3(0, 0, 0)
var distance_to_make = 0
var distance_traveled = 0
var cell_targeted = null

var damage_amout
var does_target_die

var cast_range = 8

func euclidean_dist(vec):
	return sqrt(pow(vec.x, 2) + pow(vec.z, 2))



func apply_on_target():
	var target = cell_targeted.character_on
	if target != null:
		target.receive_damage(damage_amout, does_target_die)



func cast(thrower, target, damages_infos):
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
	
	cell_targeted = target
	damage_amout = get_damage_amout(damages_infos)# /!\ UGLY SOLUTION, TEMPORARY WHILE WE CHOOSE A BETTER
	does_target_die = is_information_target_die(damages_infos) # ONLY ONE TARGET FOR NOW
	# SOLUTION TO APPLY DAMAGE AND EFFECT ON CHARACTERS (FOR NOW ON, ONLY ONE TARGET)
	is_casting = true


func get_damage_amout(damages_infos):
	if len(damages_infos) == 0 :
		return 0
	return damages_infos[0]['damage']

func is_information_target_die(damages_infos):
	if len(damages_infos) == 0:
		return false
	if 'event' in damages_infos[0].keys():
		if 'character dead' in damages_infos[0]['event'] :
			return true
	return false
	
	
	
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
			apply_on_target()


func display_touched_cells(map, origin_cell, target_cell, color_key):
	if map.is_in_fov(origin_cell, cast_range, target_cell):
		target_cell.change_material(color_key)
	return target_cell

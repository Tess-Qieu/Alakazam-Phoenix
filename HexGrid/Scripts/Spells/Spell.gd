extends KinematicBody
class_name Spell

var rng = RandomNumberGenerator.new()

export var speed = 10

var is_casting = false
var vect = Vector3(0, 0, 0)
var distance_to_make = 0
var distance_traveled = 0
var cell_targeted = null

var damage_amount = [-1,-1]
var does_target_die
# Variable allowing to memorize damages information untill applying them
var damages_info_memory

var cast_range = [1,3]
var start_cooldown = 10
var current_cooldown
var miniature = preload("res://icon.png")
var fov_type = 'fov'
var impact_type = 'cell'

func euclidean_dist(vec):
	return sqrt(pow(vec.x, 2) + pow(vec.z, 2))

func _ready():
	rng.randomize()

func compute_damages_on(target_cell, touched_cells, caster_team):
	# target_cell is not used here, but could be used to deal damages
	#  based on distance from the targeted cell
	
	var damages_info = []
	var target_character = null
	var dmg
	var is_dead = false
	var info
	
	# Touched characters research
	for cell in touched_cells:
		if cell.has_character_on():
			# Damages dealt only on opposing team
			if not caster_team.has_member(cell.character_on):
				
				info = {}
				target_character = cell.character_on
				
				dmg = rng.randi_range(damage_amount[0], \
										damage_amount[1])
				
				info = {'id character'	: target_character.id_character,
						'damage'		: dmg,
						'events'		: [],
						'character'		: target_character
						}
				
				is_dead = target_character.current_health - dmg <= 0
				
				if is_dead:
					info['events'] += ['character dead']
				
				damages_info.append(info)
	
	return damages_info

func apply_on_target():
	# Damages informations are like this:
	#	id character: ID as int
	#	damage		: Amount as int
	#	events		: array of string
	#	character	: reference to touched character
	for info in damages_info_memory:
		if info['character'] != null: 
			var is_dead = 'character dead' in info['events']
			info['character'].receive_damage(info['damage'], is_dead)
	
	# Reset memory
	damages_info_memory = {}



func cast(thrower, target, damages_infos):
	# Translate the ball in front of the character
	# and prepare the throw
	translation = Vector3(0, 2, 0) # set to origin, 2m high
	visible = true
	
	vect = target.translation - thrower.translation
	distance_to_make = euclidean_dist(vect)
	vect = vect / distance_to_make
	
	translation += 1*vect
	distance_traveled = 1.5*euclidean_dist(vect)
	
	# Save information until applying damages
	damages_info_memory = damages_infos 
	
	# Activate animation
	cell_targeted = target
	is_casting = true


func get_damage_amount(damages_infos):
	if len(damages_infos) == 0 :
		return 0
	return damages_infos[0]['damage']

func is_information_target_die(damages_infos):
	if len(damages_infos) == 0:
		return false
	if 'events' in damages_infos[0].keys():
		if 'character dead' in damages_infos[0]['events'] :
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
#			queue_free()
			apply_on_target()

extends KinematicBody

signal character_selected
signal character_movement_finished
signal character_dead


var Spell = preload("res://Scenes/Spell.tscn")


# Movement variables
export var speed = 250 #NOT WORKING IF speed > 250

var moving = false
var destination_path

const MVT_MARGIN = 0.01 # Movement margin used to discriminate if the character has arrived on a cell



# Stats informations
var current_cell setget set_current_cell

const START_HEALTH = 15 
var current_health

const START_RANGE_DISPLACEMENT = 5
var current_range_displacement



## GENERAL SECTION ##
func init(cell, team, battle_scene):
	translation.x = cell.translation.x
	translation.y = 1.5
	translation.z = cell.translation.z
	set_current_cell(cell)
	change_material(team)
	
	current_health = START_HEALTH
	current_range_displacement = START_RANGE_DISPLACEMENT
	
	# warning-ignore:return_value_discarded
	connect("character_selected", battle_scene, "_on_character_selected", [self])
	# warning-ignore:return_value_discarded
	connect("mouse_entered", battle_scene, "_on_character_hovered", [self])
	# warning-ignore:return_value_discarded
	connect("character_movement_finished", battle_scene, \
			"_on_character_movement_finished")
	# warning-ignore:return_value_discarded
	connect("character_dead", battle_scene, "_on_character_dead", [self])

func _physics_process(delta):
	if moving:
		_process_movement(delta)
		
func change_material(material_key):
	$MeshInstance.set_surface_material(0, Global.materials[material_key])

func die():
	change_material('grey')
	current_range_displacement = 0
	emit_signal("character_dead")	





## GETTERS AND SETTERS ##
func set_current_cell(cell):
	if current_cell != null:
		current_cell.kind = 'floor'
		current_cell.character_on = null
	current_cell = cell
	current_cell.kind = 'blocked'
	current_cell.character_on = self



## SPELL SECTION ##
func cast_spell(target):
	var to_look = target.translation
	to_look.y = translation.y
	look_at(to_look, Vector3(0, 1, 0))
	
	var spell = Spell.instance()
	spell.cast(current_cell, target)
	get_parent().add_child(spell)

func apply_dmg(dmg_amount):
	$AnimationPlayer.play("receive_dmg")
	if current_health - dmg_amount < 0:
		die()
	else:
		current_health -= dmg_amount




## MOVEMENT SECTION ##
func teleport_to(cell):
	set_current_cell(cell)
	translation.x = cell.translation.x
	translation.z = cell.translation.z

func move_following_path(path):
	destination_path = path
	moving = true
	$AnimationPlayer.play("movement",-1,speed/100.0)

func _process_movement(delta):
	# First, the distance between the destination cell and the character 
	#  position is calculated
	var dist = destination_path[0].translation - translation
	dist.y = 0 # Distance is only considered in (x,z) plan
	
	# if the character has not reached the destination cell
	if dist.length() > MVT_MARGIN:
		# character orientation to the destination cell
		var to_look = destination_path[0].translation
		to_look.y = translation.y
		look_at(to_look, Vector3(0,1,0))
		
		# Character velocity direction calculation
		var velocity = destination_path[0].translation - translation
		velocity.y = 0
		velocity = velocity.normalized()
		
		# Velocity value calculation
		velocity = velocity * speed * delta
		
		# Movement action
		# warning-ignore:return_value_discarded
		move_and_slide(velocity)
		
	else: # If the character has reached the cell (within a margin)
		# The character is teleported to the exact cell location
		#  in order to avoid an error accumulation
		teleport_to(destination_path[0])
		
		# If the cell is not the final destination, the movement continues
		#  to the next cell
		if destination_path.size() > 1:
			destination_path.pop_front()
			$AnimationPlayer.play("movement",-1,speed/100.0)
		else:
			moving = false
			emit_signal("character_movement_finished")





## EVENT SECTION ##
func _on_Character_input_event(_camera, event, _click_position, \
								_click_normal, _shape_idx):
	# If the event is a mouse click
	if event is InputEventMouseButton and event.pressed:
		# A different material is applied on each button
		if event.button_index == BUTTON_LEFT :
			emit_signal("character_selected")
			
		elif event.button_index == BUTTON_RIGHT:
			pass

extends KinematicBody

signal character_selected
signal character_movement_finished
signal character_die


var Spell = preload("res://Scenes/Spell.tscn")


# Movement variables
export var speed = 150 #NOT WORKING IF speed > 250
const MVT_MARGIN = 0.02 # Movement margin used to discriminate if the character has arrived on a cell

var moving = false
var destination_cell



# Stats informations
var current_cell

const START_HEALTH = 15 
var current_health

const START_RANGE_DISPLACEMENT = 10
var current_range_displacement



## GENERAL SECTION ##
func init(cell, team, battle_scene):
	translation.x = cell.translation.x
	translation.y = 1
	translation.z = cell.translation.z
	change_material(team)
	
	current_health = START_HEALTH
	current_range_displacement = START_RANGE_DISPLACEMENT
	
	# warning-ignore:return_value_discarded
	connect('character_selected', battle_scene, '_on_character_selected', [self])
	# warning-ignore:return_value_discarded
	connect('mouse_entered', battle_scene, '_on_character_hovered', [self])
	# warning-ignore:return_value_discarded
	connect('character_movement_finished', battle_scene, \
			'_on_character_movement_finished')
	# warning-ignore:return_value_discarded
	connect('character_die', battle_scene, '_on_character_die', [self])
	
	connect("input_event", self, "_on_Character_input_event")

func _physics_process(delta):
	if moving:
		_process_movement_one_cell(delta)

func change_material(material_key):
	$BodyBottom/BodyTorso.set_surface_material(0, Global.materials[material_key])
#	$MeshInstance.set_surface_material(0, Global.materials[material_key])

func unselect():
	$AnimationPlayer.stop()




## SPELL SECTION ##
func cast_spell(target):
	var to_look = target.translation
	to_look.y = translation.y
	look_at(to_look, Vector3(0, 1, 0))
	
	var spell = Spell.instance()
	spell.cast(current_cell, target)
	get_parent().add_child(spell)



## DAMAGE SECTION ##
func die(battle_scene):
	change_material('grey')
	current_range_displacement = 0
	
	disconnect('character_selected', battle_scene, '_on_character_selected')
	disconnect('mouse_entered', battle_scene, '_on_character_hovered')
	disconnect('character_movement_finished', battle_scene, \
			'_on_character_movement_finished')

func receive_damage(dmg_amount):
	$AnimationPlayer.play("Receive_Dmg")
	current_health -= dmg_amount
	if current_health <= 0:
		emit_signal('character_die')


## MOVEMENT SECTION ##
func teleport_to(cell):
	translation.x = cell.translation.x
	translation.z = cell.translation.z
	emit_signal("character_movement_finished", self, cell)

func move_to(cell):
	destination_cell = cell
	moving = true
	$AnimationPlayer.play("Walking")

func _process_movement_one_cell(delta):
	# First, the distance between the destination cell and the character 
	#  position is calculated
	var dist = destination_cell.translation - translation
	dist.y = 0 # Distance is only considered in (x,z) plan
	
	# if the character has not reached the destination cell
	if dist.length() > MVT_MARGIN:
		# character orientation to the destination cell
		var to_look = destination_cell.translation
		to_look.y = translation.y
		look_at(to_look, Vector3(0,1,0))
		
		# Character velocity direction calculation
		var velocity = destination_cell.translation - translation
		velocity.y = 0
		velocity = velocity.normalized()
		
		# Velocity value calculation
		velocity = velocity * speed * delta
		
		# Movement action
		# warning-ignore:return_value_discarded
		move_and_slide(velocity)
		
	else: # If the character has reached the cell (within a margin)
		# The character is teleported to the exact cell location
		#  in order to avoid an error accumulation and movement is stopped
#		moving = false
		teleport_to(destination_cell)

func stop_movement():
	moving = false
	$AnimationPlayer.play("Wait")





## EVENT SECTION ##
func _on_Character_input_event(_camera, event, _click_position, \
								_click_normal, _shape_idx):
	# If the event is a mouse click
	if event is InputEventMouseButton and event.pressed:
		# A different material is applied on each button
		if event.button_index == BUTTON_LEFT :
			emit_signal("character_selected")
			$AnimationPlayer.play("Wait")
			
		elif event.button_index == BUTTON_RIGHT:
			pass

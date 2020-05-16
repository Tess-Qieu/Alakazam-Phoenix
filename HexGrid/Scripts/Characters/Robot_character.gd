extends Character
class_name RobotCharacter

signal character_selected
signal character_movement_finished

## RESSOURCE IMPORT ##
var Spell = preload("res://Scenes/Spells/Spell.tscn")

# Movement variables
export var speed = 150
const MVT_MARGIN = 0.02 # Movement margin used to discriminate if the character has arrived on a cell
var moving = false
var destination_cell


## Stats informations ##
var current_cell
var id_character


var start_range_displacement = 5
var current_range_displacement



## GENERAL SECTION ##
func init(cell, c_team, c_id_character, health, range_displacement,  battle_scene):
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	translation.x = cell.translation.x
	translation.y = 1
	translation.z = cell.translation.z
	team_color = c_team
	change_material(c_team)
	
	id_character = c_id_character
	
	start_health = health
	current_health = health
	start_range_displacement = range_displacement
	current_range_displacement = range_displacement
	my_name = c_team + "_Joe_{0}".format([rng.randi_range(0,255)])
	
	# warning-ignore:return_value_discarded
	connect('character_selected', battle_scene, '_on_character_selected', [self])
	# warning-ignore:return_value_discarded
	connect('mouse_entered', battle_scene, '_on_character_hovered', [self])
	# warning-ignore:return_value_discarded
	connect('character_movement_finished', battle_scene, \
			'_on_character_movement_finished')
	# warning-ignore:return_value_discarded
	connect('character_die', battle_scene, '_on_character_die', [self])
	# warning-ignore:return_value_discarded
	connect("input_event", self, "_on_Character_input_event")
	
	# Miniature update
	miniature = load("res://Prefabs/Character/Robot_miniature.png")

func _physics_process(delta):
	if moving:
		_process_movement_one_cell(delta)

func change_material(material_key):
	$Armature/TorsoBoneAttachment/BodyTorso.set_surface_material(0, Global.materials[material_key])

func unselect():
	$AnimationPlayer.stop()




## THROW SPELL SECTION ##
func cast_spell(target, damages_infos):
	var to_look = target.translation
	to_look.y = translation.y
	look_at(to_look, Vector3(0, 1, 0))
	
	var spell = Spell.instance()
	spell.cast(current_cell, target, damages_infos)
	get_parent().add_child(spell)



## DAMAGE SECTION ##
func die(battle_scene):
	change_material('grey')
	current_range_displacement = 0
	
	disconnect('character_selected', battle_scene, '_on_character_selected')
	disconnect('mouse_entered', battle_scene, '_on_character_hovered')
	disconnect('character_movement_finished', battle_scene, \
			'_on_character_movement_finished')

func receive_damage(dmg_amount, is_dead):
	$AnimationPlayer.play("Receive_Dmg")
	current_health -= dmg_amount
	
	if is_dead:
		emit_signal('character_die')
	else:
		emit_signal("character_hurt", current_health)


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

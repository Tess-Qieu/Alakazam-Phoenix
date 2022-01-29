extends KinematicBody
class_name Character

## Ressource import ##
var miniature = preload("res://icon.png")

## Signals definition ##
signal character_hurt
signal character_die
signal character_selected
signal character_movement_finished

## Movement management ##
# Time to move from a cell to an other
const MVT_TIME = 0.75
# Node computing and animating the translation from a cell to an other
onready var my_tween
var moving = false
var destination_cell = null


## ID informations ##
var id_character
var team_color
var user_id

## Stats informations ##
var start_health = 15 
var current_health
var start_range_displacement = 5
var current_range_displacement

## Battle informations ##
var current_cell

## Spells List ##
var Spells = {'CannonBall' : "res://Scenes/Spells/RaySpell.tscn",
				'Missile'  : "res://Scenes/Spells/BombSpell.tscn",
			'Flamethrower' : "res://Scenes/Spells/BreathSpell.tscn"}


## GENERAL SECTION ##
func init(cell, c_team, c_id_character, c_user_id, health, range_displacement,  battle_scene):
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	translation.x = cell.translation.x
	translation.y = 1
	translation.z = cell.translation.z
	team_color = c_team
	change_material(c_team)
	
	id_character = c_id_character
	user_id = c_user_id
	
	start_health = health
	current_health = health
	start_range_displacement = range_displacement
	current_range_displacement = range_displacement
	name = c_team + "_Joe_{0}".format([rng.randi_range(0,255)])
	
	# warning-ignore:return_value_discarded
	connect('character_selected', battle_scene, '_on_character_clicked', [self])
	# warning-ignore:return_value_discarded
	connect('mouse_entered', battle_scene, '_on_character_hovered', [self])
	# warning-ignore:return_value_discarded
	connect('character_movement_finished', battle_scene, \
			'_on_character_movement_finished')
	# warning-ignore:return_value_discarded
	connect('character_die', battle_scene, '_on_character_die', [self])
	# warning-ignore:return_value_discarded
	connect("input_event", self, "_on_Character_input_event")
	
	# Loading of each character's spell, in order to prevent loading delay 
	#  during a game
	for k in Spells.keys():
		Spells[k] = load(Spells[k]).instance()
	
	# tween instatiation for computing movement
	my_tween = Tween.new()
	add_child(my_tween)
	my_tween.connect("tween_completed", self, "_on_tween_completed")

func unselect():
	$AnimationPlayer.stop()

func select():
	$AnimationPlayer.play("Wait")

func is_alive():
	return current_health > 0





## THROW SPELL SECTION ##
func cast_spell(target, spell_id, damages_infos):
	var to_look = target.translation
	to_look.y = translation.y
	look_at(to_look, Vector3(0, 1, 0))
	
	Spells[spell_id].cast(current_cell, target, damages_infos)
#	var spell = Spells['CannonBall'].instance()
#	spell.cast(current_cell, target, damages_infos)
	if Spells[spell_id].get_parent() == null:
		add_child(Spells[spell_id])





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
func _on_tween_completed(_obj, _key):
	# At in_between animation completion, signal the movement completion.
	#  This signal is handled outside the character 
	emit_signal("character_movement_finished", self, destination_cell)

func move_to(cell):
	# Memorizing destination cell
	destination_cell = cell
	
	# Direction change, rotating on Y axis
	var to_look = destination_cell.translation
	to_look.y = translation.y
	look_at(to_look, Vector3(0,1,0))
	
	# Movement animation
	if not moving:
		$AnimationPlayer.play("Walking")
		moving = true
	
	# The movement is computed from the origin cell to the destination cell,
	#  at character's height
	var init_pos = Vector3(current_cell.translation.x, 
						translation.y, 
						current_cell.translation.z)
	var final_pos = Vector3(destination_cell.translation.x, 
							translation.y, 
							destination_cell.translation.z)
	my_tween.interpolate_property(self, "translation", init_pos, final_pos, 
								MVT_TIME)
	my_tween.start()

func stop_movement():
	moving = false
	$AnimationPlayer.play("Wait")







## EVENT SECTION ##
func _on_Character_input_event(_camera, event, _click_position, \
								_click_normal, _shape_idx):
	# If the event is a mouse click
	if event is InputEventMouseButton and event.pressed:
		
		if event.button_index == BUTTON_LEFT :
			emit_signal("character_selected")

## INHERETED FUNCTIONS ##
# warning-ignore:unused_argument
func change_material(material_key):
	pass

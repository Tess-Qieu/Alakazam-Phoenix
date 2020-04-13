extends KinematicBody

signal character_selected

var Spell = preload("res://Scenes/Spell.tscn")

var current_cell
var destination

const MVT_MARGIN = 0.01

# Movement variables
export var speed = 100 
var moving = false

func init(cell, team):
	translation.x = cell.translation.x
	translation.y = 1.5
	translation.z = cell.translation.z
	current_cell = cell
	change_material(team)
	
func cast_spell(target):
	var to_look = target.translation
	to_look.y = translation.y
	look_at(to_look, Vector3(0, 1, 0))
	
	var spell = Spell.instance()
	spell.cast(current_cell, target)
	get_parent().add_child(spell)
	
func teleport_to(cell):
	current_cell = cell
	translation.x = cell.translation.x
	translation.z = cell.translation.z
	
	
func change_material(material_key):
	$MeshInstance.set_surface_material(0, Global.materials[material_key])


func _on_Character_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	# If the event is a mouse click
	if event is InputEventMouseButton and event.pressed:
		# A different material is applied on each button
		if event.button_index == BUTTON_LEFT :
			emit_signal("character_selected")
			
		elif event.button_index == BUTTON_RIGHT:
			pass

func set_destination(cell):
	destination = cell
	moving = true
	$AnimationPlayer.play("movement")

func _physics_process(delta):
	if moving:
		_process_movement(delta)
			
func _process_movement(delta):
	var dist = destination.translation - translation
	dist.y = 0
	print("Dist: {0}".format([dist.length()]))
	if dist.length() > MVT_MARGIN:
		var to_look = destination.translation
		to_look.y = translation.y
		look_at(to_look, Vector3(0,1,0))
		var velocity = destination.translation - translation
		velocity.y = 0
		velocity = velocity.normalized()
		velocity = velocity * speed * delta
		move_and_slide(velocity)
	else:
		print("STAHP!")
		moving = false
		$AnimationPlayer.stop()
		teleport_to(destination)

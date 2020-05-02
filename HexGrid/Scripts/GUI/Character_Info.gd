extends PanelContainer


onready var current_life_txt = $VBoxContainer/HBoxContainer2/Infos/Health_Bar/Life/Value
onready var current_life_bar = $VBoxContainer/HBoxContainer2/Infos/Health_Bar/Life_Bar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func connect_character(character, team):
	# Character specific configuration
	$VBoxContainer/Title/Name.text = character.my_name
	$VBoxContainer/HBoxContainer2/Icon/Character.texture = character.miniature
	$VBoxContainer/HBoxContainer2/Infos/Health_Bar/Life/Max.text = \
		"/{0}".format([character.start_health])
	current_life_bar.max_value = character.start_health
	update_life(character.current_health)
	
	# Team relative configuration
	$VBoxContainer/HBoxContainer2/Icon/Team_Bkgnd \
		.self_modulate = Global.materials[team].albedo_color

func update_life(new_val):
	current_life_bar.value = new_val
	current_life_txt.text = "{0}".format([new_val])


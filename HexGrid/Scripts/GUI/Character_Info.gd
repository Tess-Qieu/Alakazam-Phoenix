extends PanelContainer


onready var current_life_txt = $VBoxContainer/HBoxContainer2/Infos/Health_Bar/Life/Value
onready var current_life_bar = $VBoxContainer/HBoxContainer2/Infos/Health_Bar/Life_Bar
const MIN_VBOX_Y = 20
const MIN_SELF_Y = 34

func _ready():
	$VBoxContainer/Title/Expand_Button.connect("pressed", self, \
		"_on_Expand_Button_pressed")

## GUI MANAGEMENT SECTION ##
func _on_Expand_Button_pressed():
	if $VBoxContainer/HBoxContainer2.visible:
		$VBoxContainer/HBoxContainer2.hide()
		$VBoxContainer.rect_size[1] = MIN_VBOX_Y
		rect_size[1]= MIN_SELF_Y
	else:
		$VBoxContainer/HBoxContainer2.show()

## CHARACTER RELATIVE SECTION ##
func connect_character(character, team):
	## Connects a character to the interface :
	#	Sets the character name as title
	#	Sets the character miniature as icon
	#	Sets maximum life of the character to textual max and health bar max
	#	Sets the icon background as the team color
	
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
	
	character.connect("character_hurt", self, "update_life" )
	character.connect("character_die", self, "character_die")

func update_life(new_val):
	## Update life value in both text info and lifebar info
	
	current_life_bar.value = new_val
	current_life_txt.text = "{0}".format([new_val])

func character_die():
	## Update of the info when the character dies
	#	Sets the background of the icon as grey
	#	Sets the life at 0
	
	# Change background color
	$VBoxContainer/HBoxContainer2/Icon/Team_Bkgnd \
		.self_modulate = Global.materials["grey"].albedo_color
	update_life(0)
	

extends PanelContainer


onready var current_life_txt = $VBoxContainer/HBoxContainer2/Infos/Health_Bar/Life/Value
onready var current_life_bar = $VBoxContainer/HBoxContainer2/Infos/Health_Bar/Life_Bar
const MIN_VBOX_Y = 20
const MIN_SELF_Y = 34

func _ready():
	# warning-ignore:return_value_discarded
	$VBoxContainer/Title/Expand_Button.connect("pressed",self,"_toggle_expansion")

## GUI MANAGEMENT SECTION ##
func _toggle_expansion():
	## Function expanding and unexpanding the Character_Info
	#  The HBox containing the character icon and lifebars is masked/unmasked
	# 	and remaining controls are resized (Manually while unexpanding, 
	#	automatically while expanding)
	
	if $VBoxContainer/HBoxContainer2.visible:
		$VBoxContainer/HBoxContainer2.hide()
		$VBoxContainer.rect_size[1] = MIN_VBOX_Y
		rect_size[1]= MIN_SELF_Y
	else:
		$VBoxContainer/HBoxContainer2.show()

## CHARACTER RELATIVE SECTION ##
func connect_character(character : Character, team_color):
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
		.self_modulate = Global.materials[team_color].albedo_color
	
	# warning-ignore:return_value_discarded
	character.connect("character_hurt", self, "update_life" )
	# warning-ignore:return_value_discarded
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
	

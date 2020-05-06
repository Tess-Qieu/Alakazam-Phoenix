extends PanelContainer

var Character_Info = preload("res://Scenes/GUI/Character_Info.tscn")

const MIN_VBOX_Y = 20
const MIN_SELF_Y = 34

## GENERAL SECTION ##

# Called when the node enters the scene tree for the first time.
func _ready():
	$Body/Header/ExpandButton.connect("pressed", self,"_toggle_expansion")

func get_team_name():
	return $Body/Header/Name.text

## TEAM MANAGEMENT SECTION ##
func config_team(team_name):
	$Body/Header/Name.text = team_name

func add_teammate(new_member, team_color):
	
	# Instanciation of a character_info object 
	var char_info = Character_Info.instance()
	$Body/Members.add_child(char_info)
	
	char_info.connect_character(new_member, team_color)
	

## GUI MANAGEMENT SECTION ##
func _toggle_expansion():
	## Function expanding and unexpanding the TeamContainer
	#  The member list is masked/unmasked, Body and Background are resized 
	#	(Manually while unexpanding, automatically while expanding)
	
	if $Body/Members.visible:
		$Body/Members.hide()
		$Body.rect_size[1] = MIN_VBOX_Y
		rect_size[1]= MIN_SELF_Y
	else:
		$Body/Members.show()

extends Control
class_name BlurredBackground_Widget

# Configuration var
export var message = "[DEFAULT]Your message here"

# Children reference var
onready var MsgLbl = $WidgetBackground/VBoxContainer/Message_Label
onready var buttonsContainer = $WidgetBackground/VBoxContainer/ButtonsContainer 

# Actions to connect to each button, in order
var actions = \
	[ 
		{	"action_name"	: "Exit game",
			"action_target"	: SceneTree,
			"action_method"	: "quit" 
		},
		{ 	"action_name"  	: "Return Main Menu",
			"action_target"	: SceneTree,
			"action_method"	: "change_scene_to",
			"action_args"  	: [Global.MainMenu] 
		}
	]

func _ready():
	MsgLbl.text = message
	# Cleaning phase
	for child in buttonsContainer.get_children():
		buttonsContainer.remove_child(child)
	for action in actions:
		if action["action_target"] == SceneTree:
			action["action_target"] = get_tree()
	
	# instanciating buttons
	for action in actions:
		var new_bt = Button.new()
		new_bt.size_flags_horizontal = SIZE_EXPAND + SIZE_SHRINK_CENTER
		new_bt.size_flags_vertical   = SIZE_EXPAND + SIZE_SHRINK_CENTER
		new_bt.name = action["action_name"]
		new_bt.text = action["action_name"]
		if "action_args" in action.keys():
			new_bt.connect("pressed", action["action_target"], \
					action["action_method"], action["action_args"])
		else:
			new_bt.connect("pressed", \
					action["action_target"], action["action_method"])
		
		buttonsContainer.add_child(new_bt)

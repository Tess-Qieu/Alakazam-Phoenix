extends PopupPanel
class_name AutoPopup

# Configuration var
export var message = "[DEFAULT]Your message here" setget set_message
export var show_delay = 1.0 #second
var observer : Control = null setget set_observer 

# Children references
onready var MsgLbl = $Label
onready var timer  = $Timer

# Internal variables
var mouse_last_pos  : Vector2
var following_mouse : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	set_message(message)
	set_observer(observer)
	timer.one_shot = true
	timer.connect("timeout", self, "place_and_show")

func _process(_delta):
	# Pop-up Management
	if following_mouse:
		# If the mouse is stopped during some time, the pop-up panel is shown
		# The pop-up menu is hidden when the mouse is moved
		if get_global_mouse_position() == mouse_last_pos:
			if timer.is_stopped() and not visible:
				timer.start(show_delay)
		else:
			hide()
			timer.stop()
		
		mouse_last_pos = get_global_mouse_position()

## ACCESSORS
func set_message(msg):
	message = msg
	if MsgLbl != null:
		MsgLbl.text = msg

func set_observer(obs : Control):
	if obs != null:
		observer = obs
		# warning-ignore:return_value_discarded
		observer.connect("mouse_entered", self, "_on_mouse_entered")
		# warning-ignore:return_value_discarded
		observer.connect("mouse_exited",  self, "_on_mouse_exited" )

func place_and_show():
	# Display popup
	show()
	
	# Size set to force panel resize when shown
	rect_size = Vector2(0.1, 0.1)
	
	# Compute correct position to avoid being outside the game window
	var popup_pos = get_global_mouse_position()
	
	# Check if popup outside window on x axis.
	if popup_pos.x + rect_size.x > OS.window_size.x:
		# If so, a negitive offset is added 
		popup_pos.x -= rect_size.x
	
	# Check if popup outside window on y axis
	if popup_pos.y + rect_size.y > OS.window_size.y:
		# If so, a negitive offset is added
		popup_pos.y -= rect_size.y
	
	# Place pop_up
	set_position(popup_pos)

## EVENT HANDLING
func _on_mouse_entered():
	following_mouse = true
	
func _on_mouse_exited():
	following_mouse = false
	hide()

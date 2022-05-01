extends VBoxContainer


## POP-UP MENU DATA ##
const APPEAR_COUNT = 45
var mouse_counter = 0
var mouse_last_pos : Vector2
var popUp : PopupPanel
var following_mouse = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	connect("mouse_entered", self, "_on_mouse_entered")
	# warning-ignore:return_value_discarded
	connect("mouse_exited", self, "_on_mouse_exited")
	# warning-ignore:return_value_discarded
	$Button.connect("mouse_entered", self, "_on_mouse_entered")
	# warning-ignore:return_value_discarded
	$Button.connect("mouse_exited", self, "_on_mouse_exited")
	# warning-ignore:return_value_discarded
	$HSlider.connect("mouse_entered", self, "_on_mouse_entered")
	# warning-ignore:return_value_discarded
	$HSlider.connect("mouse_exited", self, "_on_mouse_exited")

func _process(delta):
	# Pop-up Management
	if following_mouse:
		# If the mouse is stopped during some time, the pop-up panel is shown
		# The pop-up menu is hidden when the mouse is moved
		if get_global_mouse_position() == mouse_last_pos:
			mouse_counter += 1
			if mouse_counter == APPEAR_COUNT:
				popUp.rect_position = get_global_mouse_position() \
							+ Vector2(-popUp.rect_size[0], 0)
				popUp.show()
		else:
			if mouse_counter >= APPEAR_COUNT:
				popUp.hide()
			mouse_counter = 0
		
		mouse_last_pos = get_global_mouse_position()

## POP-UP MANAGEMENT SECTION
func _on_mouse_entered():
	following_mouse = true
	
func _on_mouse_exited():
	following_mouse = false
	popUp.hide()

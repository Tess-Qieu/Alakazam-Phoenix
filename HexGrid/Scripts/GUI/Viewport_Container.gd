extends ViewportContainer

onready var viewport = get_child(0)

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventMouse:
		var mouseEvent = event.duplicate()
		mouseEvent.position = get_global_transform().xform_inv(event.global_position)
		viewport.unhandled_input(mouseEvent)
	else:
		viewport.unhandled_input(event)

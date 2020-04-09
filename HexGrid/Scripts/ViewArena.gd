extends ViewportContainer

# Fix the object pickable problem with viewport
func _input(event):
	if event is InputEventMouse:
		event.position -= rect_global_position
	$Viewport.unhandled_input(event)

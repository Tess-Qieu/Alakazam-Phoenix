extends Button

## POP-UP MENU DATA ##
const APPEAR_COUNT = 15
var mouse_counter = 0
var mouse_last_pos : Vector2
var following_mouse : bool

## GENERAL SECTION ##
func _ready():
	connect("mouse_entered", self, "_on_SpellButton_mouse_entered")
	connect("mouse_exited", self, "_on_SpellButton_mouse_exited")

func initialize(spell_key, spell : Spell):
	icon = spell.miniature
	name = spell_key
	
	# Cooldown memorization
	$Cooldown_label.text = String(spell.current_cooldown)
	if spell.current_cooldown != 0:
		disabled = true
		$Cooldown_label.show()
	else:
		$Cooldown_label.hide()
		disabled = false

func _process(delta):
	# Pop-up Management
	if following_mouse:
		# If the mouse is stopped during some time, the pop-up panel is shown
		# The pop-up menu is hidden when the mouse is moved
		if get_global_mouse_position() == mouse_last_pos:
			mouse_counter += 1
			if mouse_counter == APPEAR_COUNT:
				$PopupPanel.rect_position = get_global_mouse_position() \
							+ Vector2(-$PopupPanel.rect_size[0], 0)
				$PopupPanel.show()
		else:
			if mouse_counter >= APPEAR_COUNT:
				$PopupPanel.hide()
			mouse_counter = 0
		
		mouse_last_pos = get_global_mouse_position()

## POP-UP MANAGEMENT SECTION
func _on_SpellButton_mouse_entered():
	following_mouse = true
	
func _on_SpellButton_mouse_exited():
	following_mouse = false
	$PopupPanel.hide()

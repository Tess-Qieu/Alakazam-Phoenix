extends Button

# TODO: shortcut already exists in Button class : investigate use
onready var spell_shortcut = $Shortcut_label
onready var spell_popup    = $Spell_Popup

## GENERAL SECTION ##
func _ready():
	spell_popup.message  = "This is a nice spell !\nDon't try the shortcut.\nIt doesn't work (yet ?)"
	spell_popup.observer = self

func initialize(spell_key, spell_icon):
	icon = spell_icon
	name = spell_key

extends Spatial

var Character = preload("res://Scenes/Character.tscn")
var team_blue = []
var team_red = []
var current_character

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	create_character('blue')
	create_character('red')
	current_character = team_blue[0]
	
func create_character(team):
	var cell = $Map.cells_floor[rng.randi_range(0, len($Map.cells_floor))]
	var character = Character.instance()
	character.init(cell, team)
	character.connect("character_selected", self, "_on_character_selected", [character])
	add_child(character)
	
	if team == 'blue':
		team_blue += [character]
	elif team == 'red':
		team_red += [character]

func _on_character_selected(character):
	$Map.clear()
	
	current_character = character
	if (character in team_blue):
		character.current_cell.change_material('blue')
	elif (character in team_red):
		character.current_cell.change_material('red')
	else:
		character.current_cell.change_material('green')

func _on_ButtonSpell_pressed():
	$Map.clear()
	var fov = $Map.display_field_of_view(current_character.current_cell, 20)

func _on_ButtonClear_pressed():
	$Map.clear()

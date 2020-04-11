extends Spatial

var Character = preload("res://Scenes/Character.tscn")

var character_1 = null

# Called when the node enters the scene tree for the first time.
func _ready():
	prepare()
	
func prepare():
	character_1 = Character.instance()
	add_child(character_1)
	var cell = $Map.get_cells_kind('floor')[0]
	put_character_on_map(character_1, cell)
	
func put_character_on_map(character, cell):
	character.translation.x = cell.translation.x
	character.translation.y = 1.5
	character.translation.z = cell.translation.z


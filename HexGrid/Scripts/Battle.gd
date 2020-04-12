extends Spatial

var Character = preload("res://Scenes/Character.tscn")
var character_1 = null

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	prepare()
	
func prepare():
	var cells_floor = $Map.get_cells_kind('floor')
	var cell = cells_floor[rng.randi_range(0, len(cells_floor))]
	character_1 = Character.instance()
	character_1.init(cell)
	add_child(character_1)


func _on_ButtonSpell_pressed():
	var fov = $Map.compute_field_of_view(character_1.current_cell, 10)
	for c in fov:
		c.change_material('green')

extends Spatial

var Character = preload("res://Scenes/Character.tscn")
var character_1 = null

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
#	prepare()
	pass
	
func prepare():
	var cells_floor = $Map.get_cells_kind('floor')
	var cell = cells_floor[rng.randi_range(0, len(cells_floor))]
	character_1 = Character.instance()
	character_1.init(cell)
	add_child(character_1)


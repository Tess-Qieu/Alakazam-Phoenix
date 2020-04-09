extends Spatial

var Player = preload("res://Scenes/Player.tscn")

var player_1 = null

# Called when the node enters the scene tree for the first time.
func _ready():
#	prepare()
	pass
	
func prepare():
	player_1 = Player.instance()
	var cell = $Map.get_cells_kind('floor')[0]
	put_player_on_map(player_1, cell)
	
func put_player_on_map(player, cell):
	player.translation = cell.translation


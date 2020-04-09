extends Spatial

var Player = preload("res://Scenes/Player.tscn")

var player_1 = null

# Called when the node enters the scene tree for the first time.
func _ready():
#	prepare()
	pass
	
func prepare():
	player_1 = Player.instance()
	add_child(player_1)
	var cell = $Map.get_cells_kind('floor')[0]
	put_player_on_map(player_1, cell)
	
func put_player_on_map(player, cell):
	player.translation.x = cell.translation.x
	player.translation.y = 1.5
	player.translation.z = cell.translation.z


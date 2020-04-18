extends Control

var lobby_id

func transform_grid_keys(grid):
	var new_grid = {}
	for q in grid.keys():
		new_grid[int(q)] = {}
		for r in grid[q].keys():
			new_grid[int(q)][int(r)] = grid[q][r]
	return new_grid
	
func send_data(data):
	# We add the game lobby id
	# We can add the state of the game too
	data['details']['id'] = lobby_id
	Global.network.send_data(data)

func _on_message(data):
	if not 'action' in data.keys():
		print('NetworkError: no key action in data.')
		return
	
	if data['action'] == 'new game':
		# Init the new Battle
		lobby_id = data['details']['id']
		var grid = transform_grid_keys(data['details']['grid'])
		
		$Battle.init(grid)
		
		data = {'action' : 'new game', 'details' : {'ready' : true}}
		send_data(data)
		
		
	else :
		print("NetworkError: action {} not known.".format([data['action']]))

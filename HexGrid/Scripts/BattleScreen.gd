extends Control

func transform_grid_keys(grid):
	var new_grid = {}
	for q in grid.keys():
		new_grid[int(q)] = {}
		for r in grid[q].keys():
			new_grid[int(q)][int(r)] = grid[q][r]
	return new_grid

func _on_message(data):
	if not 'action' in data.keys():
		print('NetworkError: no key action in data.')
		return
	
	if data['action'] == 'new game':
		if 'grid' in data['details'].keys():
			var grid = transform_grid_keys(data['details']['grid'])
			print(grid)
			$Battle.init(grid)
		else:
			print('NetworkError: no key grid in details for new game action.')
	
	else :
		print("NetworkError: action {} not known.".format([data['action']]))

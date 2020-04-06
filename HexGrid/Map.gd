extends Spatial

var Cell_White = preload("res://Prefabs/Cell/Cell_White/Cell_White.tscn")
var Cell_Grey = preload("res://Prefabs/Cell/Cell_Grey/Cell_Grey.tscn")

var rng = RandomNumberGenerator.new()
var grid = []

const PROBA_CELL_FULL = 0.15
const PROBA_CELL_HOLE = 0.15
const RAY = 6


func _ready():
	rng.randomize()
	generate_grid()
	instance_map()

func random_kind():
	var value = rng.randf()
	var lim = PROBA_CELL_FULL
	if value  < lim:
		return 'full'
	lim += PROBA_CELL_HOLE
	if value < lim:
		return 'hole'
	return 'floor'
	
func generate_one_line(line_size, q, r):
	var kind = ''
	for _i in range(line_size):
		kind = random_kind()
		grid[r + RAY] += [{'q': q, 'r': r, 'kind': kind}]
		q += 1
	return q

func generate_grid():
	var nb_cell = RAY + 1
	var q = 0
	var r = -RAY
	for _i in range(RAY) :
		grid += [[]]
		q = generate_one_line(nb_cell, q, r)
		nb_cell += 1
		r += 1
		q = -RAY -r
	for _i in range(RAY + 1) :
		self.grid += [[]]
		q = generate_one_line(nb_cell, q, r)
		r += 1
		q = -RAY
		nb_cell -= 1

func instance_cell(cell_type, q, r, kind, height=0):
	var cell = cell_type.instance()
	cell.init(q, r, kind, height)
	add_child(cell)
	
func instance_map():
	for line in grid:
		for c in line:
			var q = c['q']
			var r = c['r']
			var kind = c['kind']
			
			if kind == 'hole':
				pass
			elif kind == 'floor': 
				instance_cell(Cell_White, q, r, kind)
			elif kind == 'full':
				instance_cell(Cell_Grey, q, r, kind)
				instance_cell(Cell_Grey, q, r, kind, 1)

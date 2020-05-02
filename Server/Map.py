import random
from collections import namedtuple

def distance_coord(q1, r1, q2, r2):
    return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2


Cell = namedtuple('Cell', ['q', 'r', 'kind'])


class Map():
    '''Contains a representation of the map'''

    PROBA_CELL_FULL = 0.1
    PROBA_CELL_HOLE = 0.1
    LENGTH_BORDER = 8
    RAY_ARENA = 8
    RAY = LENGTH_BORDER + RAY_ARENA

    def __init__(self):
        self.grid = {}
        self.cells_floor = []
        self.generate_grid()

    def serialize(self):
        grid_serialized = {}
        for q in self.grid.keys():
            grid_serialized[q] = {}
            for r in self.grid[q].keys():
                grid_serialized[q][r] = self.get_cell(q, r).kind
        return grid_serialized

    def random_cells_floor(self, nb=2):
        cells = []
        while nb > 0:
            cell = random.choice(self.cells_floor)
            if cell not in cells:
                cells += [cell]
                nb -= 1
        return cells

    def get_cell(self, q, r):
        try:
            return self.grid[q][r]
        except KeyError:
            return None
 

    ## GRID GENERATION ##
    def generate_grid(self):
        
        def _add_instance_to_grid(self, kind, q, r):
            if not q in self.grid.keys():
                self.grid[q] = {}

            instance = Cell(q, r, kind)
            self.grid[q][r] = instance

            if kind == 'floor':
                self.cells_floor += [instance]

        def _random_kind(self):
            value = random.random()
            lim = self.PROBA_CELL_FULL
            if value  < lim:
                return 'full'
            lim += self.PROBA_CELL_HOLE
            if value < lim:
                return 'hole'
            return 'floor'
            
        def _generate_one_gridline(self, line_size, r):
            kind = ''
            half = int(line_size / 2 if line_size % 2 == 0 else (line_size / 2 + 1))
            q = -self.RAY -r if r <= 0 else -self.RAY
            # first part : random
            for i in range(half):
                if distance_coord(q, r, 0, 0) > self.RAY_ARENA:
                    kind = 'border'
                else:
                    kind = _random_kind(self)
                _add_instance_to_grid(self, kind, q, r)
                if line_size % 2 == 0 or i + 1 != half :
                    _add_instance_to_grid(self, kind, line_size - 2*i + q - 1, r)
                q += 1

        nb_cell = self.RAY + 1
        for r in range(-self.RAY, 0) :
            _generate_one_gridline(self, nb_cell, r)
            nb_cell += 1
        for r in range(self.RAY + 1) :
            _generate_one_gridline(self, nb_cell, r)
            nb_cell -= 1


    def is_path_valid(self, cell_start, path):

        def _is_neighbors(cell_1, cell_2):

            vect = (cell_1.q - cell_2.q, cell_1.r - cell_2.r)
            coord_neighbors = [(0, 1), (1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1)]
            for c in coord_neighbors:
                if vect == c:
                    return True
            return False

        if cell_start is None:
            return False
        for c in path:
            if c is None:
                return False

        current_cell = cell_start
        for cell in path:
            if not _is_neighbors(cell, current_cell):
                return False
            current_cell = cell
        return True



    def is_target_in_field_of_view(self, cell_from, cell_target):

        def _line_step(start, end, step):
            # Function used to calulate a step on a line    
            return start + (end-start)*step

        def _compute_line(self, start, end):
            # Line calculation between two cells
            line = []
            N = int(distance_coord(start.q, start.r, end.q, end.r))
            
            #Addition of starting cell
            line.append(start)
            
            for i in range(1,N):
                # float coordinates calculation
                r_float = _line_step(start.r, end.r, float(i)/float(N))
                q_float = _line_step(start.q, end.q, float(i)/float(N))
                
                # Compute all r for that step
                list_r = []
                if abs(r_float % 1) == 0.5:
                    list_r += [int(r_float - 0.5), int(r_float + 0.5)]
                else:
                    list_r += [int(round(r_float))]
                
                # Compute all q for that step
                list_q = []
                if abs(q_float % 1) == 0.5:
                    list_q += [int(q_float - 0.5), int(q_float + 0.5)]
                else:
                    list_q += [int(round(q_float))]
                
                for q in list_q:
                    for r in list_r:
                        cell = self.get_cell(q, r)
                        if cell is not None:
                            line.append(cell)
            
            # Addition of ending cell
            line.append(end)
            return line

        if cell_from is None or cell_target is None:
            return False

        first_line = _compute_line(self, cell_from, cell_target)
        second_line = _compute_line(self, cell_target, cell_from)
        for c in first_line + second_line:
            if c.kind == 'border' or c.kind == 'full':
                return False
        return True
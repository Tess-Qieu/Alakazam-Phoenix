import random
from collections import namedtuple

def distance_coord(q1, r1, q2, r2):
    return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2


Coord = namedtuple('Coord', ['q', 'r'])


class Map():
    '''Contains a representation of the map'''

    PROBA_CELL_FULL = 0.1
    PROBA_CELL_HOLE = 0.1
    LENGTH_BORDER = 8
    RAY_ARENA = 8
    RAY = LENGTH_BORDER + RAY_ARENA

    def __init__(self):
        self.grid = {}
        self.coords_floor = []
        self.generate_grid()


    def random_coords_floor(self, nb=2):
        coords = []
        while nb > 0:
            coord = random.choice(self.coords_floor)
            if coord not in coords:
                coords += [coord]
                nb -= 1
        return coords
 

    ## GRID GENERATION ##
    def generate_grid(self):
        
        def _add_instance_to_grid(self, instance, q, r):
            if not q in self.grid.keys():
                self.grid[q] = {}
            self.grid[q][r] = instance

            if instance == 'floor':
                self.coords_floor += [Coord(q, r)]

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


    def is_path_valid(self, coord_start, path):

        def _is_neighbors(coord_1, coord_2):

            coord_diff = (coord_1[0] - coord_2[0], coord_1[1] - coord_2[1])
            coord_neighbors = [(0, 1), (1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1)]
            for c in coord_neighbors:
                if coord_diff == c:
                    return True
            return False

        current_coord = coord_start
        for c in path:
            coord = (c[0], c[1]) # attention string ici
            if not _is_neighbors(coord, current_coord):
                return False
            current_coord = coord
        return True

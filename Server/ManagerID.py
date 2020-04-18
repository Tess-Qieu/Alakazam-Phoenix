#!/usr/bin/env python3

class ManagerID():
    """ Keep in memory all free games ids."""
    
    def __init__(self, N=1000000):
        self.ids = list(range(N))

    def get_new_id(self):
        return self.ids.pop(0)

    def free_id(self, id):
        self.ids += [id]
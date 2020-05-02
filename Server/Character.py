#!/usr/bin/env python3

class Character():
    ''' Reprensent a chatacter in the game '''

    def __init__(self, team, user, q, r, id_character):
        self.team = team
        self.user = user
        self.q = q
        self.r = r
        self.id_character = id_character

        self.health = 100
        self.range_displacement = 5

    def serialize(self):
        # Serialize the object to send it to the clients
        data = {'team': self.team,
                'q': self.q,
                'r': self.r,
                'id character': self.id_character,
                'health': self.health,
                'range displacement': self.range_displacement}
        return data

    def spell(self, target):
        pass

    def cast_spell(self, cell_target):
        pass

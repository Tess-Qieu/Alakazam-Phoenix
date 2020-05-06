#!/usr/bin/env python3

import random

def distance_coord(q1, r1, q2, r2):
    return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2


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
        self.alive = True

    def die(self):
        # Make the character die, /!\ MAYBE NEED TO RAISE SOMETHING FOR GAME
        self.alive = False
        self.health = 0

    def serialize(self):
        # Serialize the object to send it to the clients
        data = {'team': self.team,
                'q': self.q,
                'r': self.r,
                'id character': self.id_character,
                'health': self.health,
                'range displacement': self.range_displacement}
        return data


    def _find_targets(self, cell_target, team, zone=1):
        # Find the character targeted by the spell
        targets = []
        for t in team:
            for c in t.characters:
                if distance_coord(c.q, c.r, cell_target.q, cell_target.r) <= zone:
                    targets += [c]
        return targets 

    def _damages_calcul(self, targets, min=17, max=23):
        # Generate damages with random number between min and max
        damages = []
        for c in targets:
            damages += [random.randint(min, max+1)]
        return damages

    def _apply_damages(self, targets, damages):
        # Apply damages to characters and create data
        data = []
        for i, c in enumerate(targets):
            # apply damage
            damage = damages[i]
            c.health -= damage
            data_one_target = {'id character': c.id_character, 'damage': damage, 'events': []}

            # Verify if character still alive       
            if c.health <= 0:
                c.die()
                data_one_target['events'] += ['character dead']

            data += [data_one_target]

        return data


    def cast_spell(self, cell_target, teams):
        # Cast the spell on the cell targeted
        targets = self._find_targets(cell_target, teams)
        damages = self._damages_calcul(targets)
        data = self._apply_damages(targets, damages)
        return data
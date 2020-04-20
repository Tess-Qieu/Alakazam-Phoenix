#!/usr/bin/env python3

import asyncio

from Lobby import Lobby
from Map import Map
from ManagerID import ManagerID


class Character():

    def __init__(self, team, q, r, id_character):
        self.team = team
        self.q = q
        self.r = r
        self.id_character = id_character

        self.health = 100
        self.range_displacement = 5

    def serialize(self):
        data = {'team': self.team,
                'q': self.q,
                'r': self.r,
                'id_character': self.id_character,
                'health': self.health,
                'range displacement': self.range_displacement}
        return data


class Game(Lobby):

    ## INITIALISATION ##
    def __init__(self, server, id_lobby, players, observators=[]):
        super().__init__(server, id_lobby, players, observators)

        self.manager_id = ManagerID()
        self.map = Map()
        self.players_ready = [False for p in self.players]
        self.started = False

        coords = self.map.random_coords_floor()
        self.team_blue = [Character('blue', coords[0].q, coords[0].r, self.manager_id.get_new_id())]
        self.team_red = [Character('red', coords[1].q, coords[1].r, self.manager_id.get_new_id())]


    async def notify_new_lobby(self):
        data = {'action': 'new game', 
                'details': {'grid': self.map.grid,
                            'team_blue': [c.serialize() for c in self.team_blue],    
                            'team_red': [c.serialize() for c in self.team_red],
                            'id': self.id_lobby
                            }
                }
        await self.notify_all(data)


    ## COMMUNICATION WITH CLIENTS ##
    async def _on_message(self, data, user):        
        if data['action'] == 'new game':
            # players send they are ready
            if data['details']['ready'] == True:
                self.set_player_ready(user)


        elif data['action'] == 'game':
            # game is running
            if data['ask'] == 'move':
                # user ask to move a character
                id_character = data['details']['id_character']
                path = data['details']['path']
                data_response = self.ask_move(id_character, path)
                await self.notify_all(data_response)

        else:
            print(f'NetworkError: action {data["action"]} not known.')


    ## ACTIONS TO DO WHEN ASK FROM CLIENT ##
    def ask_move(self, id_character, path):
        character = self.get_character_by_id(id_character)
        if character is None:
            print(f'NetworkValueError: no character with id {is_character}.')
            return

        coord_start = (character.q, character.r)
        is_valid = self.map.is_path_valid(coord_start, path)
        if is_valid: 
            data = {'action': 'game', 
                    'response': 'move',
                    'details': {'id_character': id_character,
                                'path': path}}
            character.q = path[-1][0]
            character.r = path[-1][1]
        else:
            data = {'action': 'game',
                    'response': 'not valid',
                    'details': {'id_character': id_character,
                                'path': path}}
        return data

    def set_player_ready(self, user):
        index = self.players.index(user)
        self.players_ready[index] = True

        # if one user isn't ready, pass
        for p in self.players_ready:
            if not p:
                return

        # else start the game
        print(f'The game in the lobby {self.id_lobby} starts !')
        self.started = True


    ## USEFULL FUNCTIONS ##
    def get_character_by_id(self, id_character):
        for c in self.team_blue + self.team_red:
            if c.id_character == id_character:
                return c
        return None


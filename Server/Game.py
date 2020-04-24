#!/usr/bin/env python3

import asyncio
import random

from Lobby import Lobby
from Map import Map
from ManagerID import ManagerID
from Character import Character


TIME_TURN = 10


class Timer():
    def __init__(self, timeout, callback):
        self._timeout = timeout
        self._callback = callback
        self._task = asyncio.ensure_future(self._job())

    async def _job(self):
        await asyncio.sleep(self._timeout)
        await self._callback()

    def cancel(self):
        self._task.cancel()



class Team():

    def __init__(self, color_team, user, characters):
        self.color_team = color_team
        self.user = user
        self.characters = characters

    def add_character(self, character):
        self.characters += [character]

    def remove_character(self, character):
        self.characters.remove(character)

    def serialize(self):
        print(self.characters)
        return [character.serialize() for character in self.characters]



class Game(Lobby):
    ''' Administrate a game depending clients actions '''

    ## INITIALISATION ##
    def __init__(self, server, id_lobby, players, observators):
        super().__init__(server, id_lobby, players, observators)

        self.character_manager_id = ManagerID(100)
        self.map = Map()
        self.players_ready = [False for p in self.players]
        self.started = False
        self.teams = []

        self.init_teams()
        self.player_on_turn = random.choice(self.players)

    def begin(self):
        Timer(TIME_TURN, self.end_turn)

    def init_teams(self):
        # Create the team's characters
        
        def _create_team(self, color_team, user, cells):
            team = Team(color_team, user, [])
            for c in cells:
                new_character = Character(color_team, user, c.q, c.r, self.character_manager_id.get_new_id())
                team.add_character(new_character)
            return team

        cells = self.map.random_cells_floor(6)
        random.shuffle(self.players)
        self.teams += [_create_team(self, 'red', self.players[0], cells[:3])]
        self.teams += [_create_team(self, 'blue', self.players[1], cells[3:])]







    ## COMMUNICATION WITH CLIENTS ##

    async def _on_message(self, data, user):
        # Manage the message from the clients

        if data['action'] == 'new game':
            # players send they are ready
            if data['details']['ready'] == True:
                self.set_player_ready(user)


        elif data['action'] == 'game':
            # game is running
            if data['ask'] == 'move':
                # user ask to move a character
                await self.ask_move(data['details'])

            elif data['ask'] == 'cast spell':
                # user ask to cast a spell
                await self.ask_cast_spell(data['details'])

        else:
            print(f'NetworkError: action {data["action"]} not known.')

    async def notify_new_lobby(self):
        # Notify the clients that the lobby is ready
        data = {'action': 'new game', 
                'details': {'grid': self.map.serialize(),
                            'team red': self.teams[0].serialize(),
                            'team blue': self.teams[1].serialize(),    
                            'id': self.id_lobby
                            }
                }
        await self.notify_all(data)


    async def end_turn(self):
        # Notify the clients when a turn end
        data = {'action': 'game',
                'directive': 'end turn'}
        Timer(10, self.end_turn)
        await self.notify_all(data)






    ## ACTIONS TO DO WHEN ASK FROM CLIENT ##

    async def ask_move(self, data):
        # Called when the user ask to move a character
        # Verify that the path is correct
        id_character = data['id character']
        path = data['path']      

        # Find the correct character
        character = self.get_character_by_id(id_character)
        if character is None:
            print(f'NetworkValueError: no character with id {is_character}.')
            return

        # Verify if the path is valid
        cell_start = self.map.get_cell(character.q, character.r)
        path_in_cell = [self.map.get_cell(c[0], c[1]) for c in path]
        is_valid = self.map.is_path_valid(cell_start, path_in_cell) 
        
        # Send the response to the clients
        if is_valid and len(path) <= character.range_displacement: 
            # make the move
            character.q = path[-1][0]
            character.r = path[-1][1]

            data = {'action': 'game', 
                    'response': 'move',
                    'details': {'id character': id_character,
                                'path': path}}

        else:
            data = {'action': 'game',
                    'response': 'not valid',
                    'details': {'id character': id_character,
                                'path': path}}

        await self.notify_all(data)


    async def ask_cast_spell(self, data):
        # Called when the user ask to move a character
        # Verify that the path is correct
        id_thrower = data['thrower']['id character']
        coord_target = data['target']

        character_thrower = self.get_character_by_id(id_thrower)
        cell_thrower = self.map.get_cell(character_thrower.q, character_thrower.r)
        cell_target = self.map.get_cell(coord_target[0], coord_target[1])

        is_valid = self.map.is_target_in_field_of_view(cell_thrower, cell_target)


        if is_valid:
            # cast the spell
            character_thrower.cast_spell(cell_target) # implémentation cette fct

            data = {'action': 'game',
                    'response': 'cast spell',
                    'details': {'thrower': {'id character': id_thrower},
                                'target': coord_target}}

        else:
            data = {'action': 'game',
                    'response': 'not valid',
                    'details': {'thrower': {'id character': id_thrower},
                                'target': coord_target}}
        await self.notify_all(data)


    def set_player_ready(self, user):
        # Called when the client indicates that he correctly load the game
        # and he is ready to play
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

    def get_all_characters(self):
        characters = []
        for team in self.teams:
            characters += team.characters
        return characters

    def get_character_by_id(self, id_character):
        for c in self.get_all_characters():
            if c.id_character == id_character:
                return c
        return None


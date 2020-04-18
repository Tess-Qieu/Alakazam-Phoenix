#!/usr/bin/env python3

import asyncio

import Map
from ManagerID import ManagerID


class Game():

    def __init__(self):
        pass


class Character():

    def __init__(self, team, q, r, id_character):
        self.team = team
        self.q = q
        self.r = r
        self.id_character = id_character

        self.health = 100
        self.range_displacement = 5

    def serialize(self):
        data = {'team' : self.team,
                'q' : self.q,
                'r' : self.r,
                'id_character' : seld.id_character,
                'health' : self.health,
                'range displacement' : self.range_displacement}
        return data




class Lobby():
    '''Reprensentant the objects containing the game and managing it'''

    def __init__(self, server, id_lobby, players, observators=[]):
        self.server = server
        self.id_lobby = id_lobby

        self.players = players
        self.players_ready = [False for p in self.players]
        self.observators = observators

        self.manager_id = ManagerID()
        self.map = Map.Map()

        coords = self.map.random_coords_floor()
        self.team_blue = [Character('blue', coords[0].q, coords[0].r, self.manager_id.get_new_id())]
        self.team_red = [Character('red', coords[1].q, coords[1].r, self.manager_id.get_new_id())] 

        


    async def notify_new_game(self):
        data = {'action' : 'new game', 
                'details' : {'grid' : self.map.grid,
                            'team_blue' : [c.serialize() for c in self.team_blue],    
                            'team_red' : [c.serialize() for c in self.team_red],
                            'id' : self.id_lobby
                            }
                }
        await self.notify_all(data)



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
                game.ask_move(id_character, path)

        else:
            print(f'NetworkError: action {data["action"]} not known.')





    # /!\ Only manage deconnection for now
    async def _quit_lobby(self, user):
        # return True if the game can continue, else False
        if user in self.players:
            # If a player quit the game, send a message to all clients
            self.players.remove(user)
            print(f'Player {user.pseudo} left the game. End of the game.')
            print(f'Player(s) {[p.pseudo for p in self.players]} go back to waiting for an opponent.')
        
            data = {'action' : 'player left', 'details' : {'user' : user.pseudo}}
            await self.notify_all(data)
            return False


        elif user in self.observators:
            # If an observator quit the game, send a message to all the clients
            self.observators.remove(user)
            print(f'Observator {user.pseudo} left the game.')

            data = {'action' : 'observator left', 'details' : {'user' : user.pseudo}}
            await self.notify_all(data)
            return True


    def set_player_ready(self, user):
        index = self.players.index(user)
        self.players_ready[index] = True

        # if one user isn't ready, pass
        for p in self.players_ready:
            if not p :
                return

        # else start the game
        print('PLAYERS READY')



    async def notify_all_players(self, data):
        for user in self.players:
            await self.server.send_data(user.websocket, data)

    async def notify_all_observators(self, data):
        for user in self.observators:
            await self.server.send_data(user.websocket, data)

    async def notify_all(self, data):
        await self.notify_all_players(data)
        await self.notify_all_observators(data)
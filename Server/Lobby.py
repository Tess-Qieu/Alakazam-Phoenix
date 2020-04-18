#!/usr/bin/env python3

import asyncio

import Map


class Game():

    def __init__(self):
        pass


class Character():

    def __init__(self, team):
        self.team = team
        self.lifepoint = 100



class Lobby():
    '''Reprensentant the objects containing the game and managing it'''

    def __init__(self, server, id_lobby, players, observators=[]):
        self.server = server
        self.id_lobby = id_lobby

        self.players = players
        self.players_ready = [False for p in self.players]
        self.observators = observators

        self.map = Map.Map()

        


    async def notify_new_game(self):
        data = {'action' : 'new game', 'details' : {'grid' : self.map.grid,
                                                    'id' : self.id_lobby}}
        await self.notify_all(data)



    async def _on_message(self, data, user):
        
        if data['action'] == 'new game':
            # players send they are ready
            if data['details']['ready'] == True:
                self.set_player_ready(user)


        elif data['action'] == 'game':
            pass

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
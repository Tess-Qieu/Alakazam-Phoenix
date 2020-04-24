#!/usr/bin/env python3

import asyncio

class Lobby():
    '''Reprensentant the objects containing the game and managing it'''

    def __init__(self, server, id_lobby, players, observators):
        self.server = server
        self.id_lobby = id_lobby

        self.players = players
        self.observators = observators



    async def notify_new_lobby(self):
        pass


    async def _on_message(self, data, user):
        pass


    # /!\ Only manage deconnection for now
    async def _quit_lobby(self, user):
        # return True if the game can continue, else False
        if user in self.players:
            # If a player quit the game, send a message to all clients
            self.players.remove(user)
            print(f'Player {user.pseudo} left the game. End of the game.')
            print(f'Player(s) {[p.pseudo for p in self.players]} go back to waiting for an opponent.')
        
            data = {'action': 'player left', 'details': {'user': user.pseudo}}
            await self.notify_all(data)
            return False


        elif user in self.observators:
            # If an observator quit the game, send a message to all the clients
            self.observators.remove(user)
            print(f'Observator {user.pseudo} left the game.')

            data = {'action': 'observator left', 'details': {'user': user.pseudo}}
            await self.notify_all(data)
            return True




    async def notify_all_players(self, data):
        for user in self.players:
            await self.server.send_data(user.websocket, data)

    async def notify_all_observators(self, data):
        for user in self.observators:
            await self.server.send_data(user.websocket, data)

    async def notify_all(self, data):
        await self.notify_all_players(data)
        await self.notify_all_observators(data)
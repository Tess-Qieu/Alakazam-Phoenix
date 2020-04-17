#!/usr/bin/env python3

import asyncio
import Lobby


class ManagerID():
    """ Keep in memory all free games ids."""
    
    def __init__(self, N=1000000):
        self.ids = list(range(N))

    def get_new_id():
        return self.ids.pop(0)

    def free_id(id):
        self.ids += [id]


class ManagerLobbys():
    """ Used by the server to manage all lobbys. """

    def __init__(self, server):
        self.lobbys = {}
        self.manager_id = ManagerID()
        self.users_waiting_to_play = []
        self.server = server # usefull to send data to clients


    async def _on_message(self, data, user):
        
        if data['action'] == 'ask to play':
            self.users_waiting_to_play += [user]

            if len(self.users_waiting_to_play) >= 2:
                # Two users are waiting, they can play
                await self.new_game()

            else:
                # Only one user is waiting to play, he has to wait
                await self.ask_to_wait(user)


        elif data['action'] == 'new game':
            pass

        else:
            print(f'NetworkError: action {data["action"]} not known.')
            return

    def _user_deconnection(self, user):
        # 
        if user in self.users_waiting_to_play:
            self.users_waiting_to_play.remove(user)



    async def ask_to_wait(self, user):
        # Ask the client to wait until the Lobby Manager find an opponent
        data = {'action' : 'ask to wait', 'details' : {}}
        await self.server.send_data(user.websocket, data)
    

    async def new_game(self):
        # Create a new game
        user_1 = self.users_waiting_to_play.pop(0)
        user_2 = self.users_waiting_to_play.pop(0)
        print(f'New game with users {user_1.pseudo} and {user_2.pseudo}.')
        
        lobby = Lobby.Lobby([user_1, user_2])

        data = {'action' : 'new game', 'details' : {'grid' : lobby.map.grid}}
        await self.server.send_data(user_1.websocket, data)
        await self.server.send_data(user_2.websocket, data)

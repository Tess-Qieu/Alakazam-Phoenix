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
        self.players_waiting_to_play = []
        self.server = server # usefull to send data to clients


    async def _on_message(self, data, user):
        
        if data['action'] == 'ask to play':
            self.players_waiting_to_play += [user]
            if len(self.players_waiting_to_play) >= 2:
                print('more than two players')
            else:
                await self.ask_to_wait(user)


        elif data['action'] == 'new game':
            pass

        else:
            print(f'NetworkError: action {data["action"]} not known.')
            return


    def new_game(self):
        pass

    async def ask_to_wait(self, user):
        data = {'action' : 'ask to wait', 'details' : {}}
        await self.server.send_data(user.websocket, data)
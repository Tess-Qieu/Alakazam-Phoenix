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

    def __init__(self):
        self.lobbys = {}
        self.manager_id = ManagerID()
        self.players_waiting_to_play = []


    def treat_request(data):
        pass
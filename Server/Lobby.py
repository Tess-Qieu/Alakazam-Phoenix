#!/usr/bin/env python3

import asyncio

import Map


class Lobby():
    '''Reprensentant the objects containing the game and managing it'''

    def __init__(self, players, observators=[]):
        self.players = players
        self.observators = observators

        self.map = Map.Map()
        print(self.map.grid)
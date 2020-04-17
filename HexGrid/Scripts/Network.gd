extends Node

# The URL we will connect to
export var websocket_url = "ws://127.0.0.1:4225"

# Our WebSocketClient instance
var _client = WebSocketClient.new()
var _pseudo = ''
var is_connected = false

func _ready():
	_client.connect("connection_closed", self, "_on_connection_closed")
	_client.connect("connection_error", self, "_on_connection_closed")
	_client.connect("connection_established", self, "_on_connection_opened")
	_client.connect("data_received", self, "_on_data_received")


func send_data(data):
	# data must be a dictionary
	var msg = JSON.print(data).to_utf8()
	print('> ' + JSON.print(data))
	_client.get_peer(1).put_packet(msg)

func connect_to_server(pseudo):
	# Initiate connection to the given URL.
	_pseudo = pseudo
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		print('Connection made with the server.')
		is_connected = true
	
	
	
	
	
	
func _on_connection_closed(was_clean = false):
	print("Connection closed, clean: ", was_clean)
	set_process(false)

func _on_connection_opened(_procotols = ''):
	var data = {'Action' : 'Connection', 'Details' : {'Pseudo' : _pseudo}}
	send_data(data)
	
func _on_data_received():
	var msg = _client.get_peer(1).get_packet().get_string_from_utf8()
	var data = JSON.parse(msg)	
	print('< ' + msg)
	
	var node_game = get_parent()
	node_game.server_receiver_node._on_message(data)

func _process(_delta):
	_client.poll()

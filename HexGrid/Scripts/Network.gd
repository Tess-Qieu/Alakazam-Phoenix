extends Node

# The URL we will connect to
export var websocket_url = "ws://127.0.0.1:4225"

# Our WebSocketClient instance
var _client = WebSocketClient.new()
var is_connected = null

func _ready():
	_client.connect("connection_closed", self, "_on_connection_closed")
	_client.connect("connection_error", self, "_on_connection_closed")
	_client.connect("connection_established", self, "_on_connection_opened")
	_client.connect("data_received", self, "_on_message")

## NETWORK USAGE ##
func send_data(data):
	# data must be a dictionary
	var msg = JSON.print(data).to_utf8()
	print('> Client : ' + str(data))
	_client.get_peer(1).put_packet(msg)

func connect_to_server():
	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		is_connected = false
		set_process(false)
	else:
		print('Connection made with the server.')
	
	
	
## NETWORK EVENTS ##
func _on_connection_closed(was_clean = false):
	print("Connection closed, clean: ", was_clean)
	set_process(false)

func _on_connection_opened(_procotols = ''):
	is_connected = true
	# Prevent the game that the connection has been made
	# (I don't really like to use get_parent(), but the network will
	# always be attached to the Game.)
	get_parent()._on_connection_to_server()

func _on_message():
	var msg = _client.get_peer(1).get_packet().get_string_from_utf8()
	var data = JSON.parse(msg).result
	data = transform_data(data)
	print('< Server : ' + str(data))
	
	Global.server_receiver_node._on_message(data)

func _process(_delta):
	_client.poll()




## DECODE FUNCTIONS ##
func string_to_int(val):
	if val == '0':
		return 0
	else:
		var new_val = int(val)
		if new_val != 0:
			return new_val
	return val

func real_to_int(val):
	var new = int(val)
	if val == new :
		return new
	return val

#func transform_one_val(v):
#	if v is Dictionary:
#		v = transform_values(v)
#	elif v is Array:
#		var new_v = []
#		for val in v:
#			val = transform_values(val)
#			new_v += [val]
#		v = new_v
#	elif v is String:
#		v = string_to_int(v)
#	elif typeof(v) == TYPE_REAL:
#		v = real_to_int(v)
#	return v
#
#func transform_values(data):
#	if data is Dictionary:
#		var new_data = {}
#		for k in data.keys():
#			var v = transform_one_val(data[k])
#			k = transform_one_val(k)
#			new_data[k] = v
#		return new_data
#
#	elif data is Array:
#		var new_data = []
#		for v in data:
#			v = transform_one_val(v)
#			new_data += [v]
#		return new_data


func transform_data(data):
	if data is Dictionary:
		var new_data = {}
		for k in data.keys():
			var v = transform_data(data[k])
			k = transform_data(k)
			new_data[k] = v
		return new_data
	
	elif data is Array:
		var new_data = []
		for v in data:
			v = transform_data(v)
			new_data += [v]
		return new_data
	
	elif data is String:
		return string_to_int(data)
	
	elif typeof(data) == TYPE_REAL:
		return real_to_int(data)
	
	else:
		return data
	




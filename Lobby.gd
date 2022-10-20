extends Node2D

var net : MyNetworkedMultiplayer

func _ready():
	net =  MyNetworkedMultiplayer.new()
	#net.connect("peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_connected", self, "_player_connected")

func _on_ButtonHost_pressed():
	print("hosting")
	get_tree().set_network_peer(net)
	net.start_host()

func _on_ButtonJoin_pressed():
	print("joining")
	get_tree().set_network_peer(net)
	net.start_client()

func _player_connected(id):
	print(str(id), ' joined')
	#Globals.player2id = id # set by CustomPeer
	if id != net.get_unique_id():
		var game = preload("res://Game.tscn").instance()
		get_tree().get_root().add_child(game)
		hide()

func _physics_process(_delta):
	if net.get_connection_status() == NetworkedMultiplayerCustom.CONNECTION_CONNECTED:
		net.poll()

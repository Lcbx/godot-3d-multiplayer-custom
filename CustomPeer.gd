extends NetworkedMultiplayerCustom
class_name MyNetworkedMultiplayer

var lastMessageTime = 0
var my_id = null

func _init():
	set_connection_status(NetworkedMultiplayerPeer.CONNECTION_CONNECTING)
	lastMessageTime = OS.get_system_time_secs()

func start_host():
	my_id = 1
	Globals.player2id = 2
	start()
	
func start_client():
	my_id = 2
	Globals.player2id = 1
	start()

func start():
	connect("packet_generated", self, "_on_custom_peer_packet_generated")
	initialize(my_id)
	set_connection_status(NetworkedMultiplayerCustom.CONNECTION_CONNECTED)
	emit_signal("peer_connected", my_id)
	emit_signal("peer_connected", Globals.player2id)


func poll():
	var file = File.new()
	var currentModifiedTime = file.get_modified_time("user://" + str(my_id))
	if  currentModifiedTime > lastMessageTime:
		lastMessageTime = currentModifiedTime
		var message = read()
		print('from', Globals.player2id, message)
		deliver_packet(message, Globals.player2id)
		#deliver_packet(message, 0)

func _on_custom_peer_packet_generated(peer_id, buffer:PoolByteArray, transfer_mode):
	# to avoid print spam + reading/writing to file is slow anyway
	if not buffer.empty() and OS.get_system_time_msecs()%21 == 0:
		print('src ', my_id, ' dest ', peer_id, ' payload ', buffer)
		write(peer_id, buffer)

## using files to comunicate between peers
## to test NetworkedMultiplayerCustom

func write(id:int, content:PoolByteArray):
	var file = File.new()
	file.open("user://" + str(id), File.WRITE)
	file.store_buffer(content)
	#file.store_string(content.get_string_from_utf8())
	#file.store_string(to_json(content))
	file.close()

func read() -> PoolByteArray:
	var file = File.new()
	file.open("user://" + str(my_id), File.READ)
	var content = file.get_buffer(file.get_len())
	#var content = file.get_as_text()
	#content = JSON.parse(content)
	#content = content.get_result()
	file.close()
	return content

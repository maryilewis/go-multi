extends Node

const PORT = 4433

@onready var place_ref := preload("res://Levels/Hello/place.tscn")
@onready var dorm_ref := preload("res://Levels/dorm/dorm.tscn")

var current_level: PackedScene

func _ready():
	$UI/VBoxContainer/Place.grab_focus()
	# Start paused.
	get_tree().paused = true
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false

	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_create_pressed.call_deferred()


func _create_level_place():
	print("create level place")
	current_level = place_ref
	_on_create_pressed()

func _create_level_dorm():
	current_level = dorm_ref
	_on_create_pressed()

func _on_create_pressed():
	print("create")
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()


func _on_join_pressed():
	print("join")
	# Start as client.
	var txt : String = $UI/VBoxContainer/Remote.text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()


func start_game():
	_on_done_pressed()
	print("start game")
	# Hide the UI and unpause to start the game.
	$UI.hide()
	get_tree().paused = false
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		change_level.call_deferred(current_level)

# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())
	print("add scene")

#region Character Options

func _on_character_pressed():
	$"Character Settings".process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	$"Character Settings".visible = true
	$"Character Settings/Panel/VBoxContainer/HBoxContainer/LineEdit".grab_focus()


func _on_line_edit_text_changed(new_text):
	CharacterManager.display_name = new_text


func _on_option_button_item_selected(index):
	CharacterManager.color_index = index


func _on_done_pressed():
	$"Character Settings".visible = false
	$"Character Settings".process_mode = Node.PROCESS_MODE_DISABLED
	#$UI/VBoxContainer/Place.grab_focus()
	
#endregion


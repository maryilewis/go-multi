# player_input.gd
extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false

# Synchronized property.
@export var direction := Vector2()

signal shirt_color_index_change(new_value)
signal name_change(new_value)

@export var shirt_material: int :
	set(mat_index):
		shirt_material = mat_index
		shirt_color_index_change.emit(mat_index)

@export var display_name: String :
	set(new_name):
		display_name = new_name
		name_change.emit(new_name)

func _ready():
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

@rpc("call_local")
func jump():
	jumping = true


func _process(_delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_action_just_pressed("ui_accept"):
		jump.rpc()

# set shirt color
func _on_shirt_color_selected(index):
	shirt_material = index

func _on_name_changed(value):
	display_name = value

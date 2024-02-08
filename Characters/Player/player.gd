# player.gd
class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var shirt_materials = []

@onready var red_mat = preload("res://Characters/character materials/shirt materials/red.tres")
@onready var orange_mat = preload("res://Characters/character materials/shirt materials/orange.tres")
@onready var yellow_mat = preload("res://Characters/character materials/shirt materials/yellow.tres")
@onready var green_mat = preload("res://Characters/character materials/shirt materials/green.tres")
@onready var blue_mat = preload("res://Characters/character materials/shirt materials/blue.tres")
@onready var purple_mat = preload("res://Characters/character materials/shirt materials/purple.tres")


# Set by the authority, synchronized on spawn.
@export var player : int :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)

@export var shirt_material: int :
	set(mat_index):
		shirt_material = mat_index
		#TODO fix initial load
		if (shirt_materials.size()):
			$MeshInstance3D.mesh.material = shirt_materials[mat_index]
			
@export var display_name: String :
	set(new_name):
		display_name = new_name
		$Name.text = new_name

# Player synchronized input.
@onready var input = $PlayerInput

func _ready():
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		$Camera3D.current = true
		$Indicator.visible = true
		$"Character Settings".process_mode = Node.PROCESS_MODE_INHERIT
		$"Character Settings".visible = true
	# Only process on server.
	# EDIT: Let the client simulate player movement too to compesate network input latency.
	set_physics_process(multiplayer.is_server())
	shirt_materials.append(red_mat)
	shirt_materials.append(orange_mat)
	shirt_materials.append(yellow_mat)
	shirt_materials.append(green_mat)
	shirt_materials.append(blue_mat)
	shirt_materials.append(purple_mat)



func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if input.jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Reset jump state.
	input.jumping = false

	# Handle movement.
	var direction = (transform.basis * Vector3(input.direction.x, 0, input.direction.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _on_player_input_shirt_color_index_change(new_value):
	shirt_material = new_value


func _on_player_input_name_change(new_value):
	display_name = new_value

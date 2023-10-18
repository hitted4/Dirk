extends CharacterBody2D
@export var player_id: int
@export var start_position: Vector2
@export var player_name: String
var color: Color
const SPEED = 200.0
const JUMP_VELOCITY = -350.0
var ui_inputs: Dictionary
var device_num: int
var use_keyboard: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_timer = 0.0
@onready var _upper_body = $UpperRotation/AnimatedSpriteUpper
@onready var _lower_body = $AnimatedSpriteLower

func _ready():
	get_node("falldeath")
	self.modulate = color
	$UpperRotation.use_keyboard = use_keyboard
	$UpperRotation/AnimatedSpriteUpper.keyboard_set(use_keyboard)
	$UpperRotation.player_id = player_id
	respawn()
func respawn():
	position = start_position
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump_%s" %[player_id]) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_timer = 0
	if Input.is_action_pressed("jump_%s" %[player_id]) and jump_timer < 0.2:
		velocity.y = JUMP_VELOCITY
		_upper_body.play("jump")
		_lower_body.play("jump")
		jump_timer += 1 * delta
	if Input.is_action_just_released("jump_%s" %[player_id]):
		jump_timer = 0.3

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left_%s" %[player_id], "move_right_%s" %[player_id])
	if direction:
		velocity.x = direction * SPEED
		if is_on_floor():
			_upper_body.play("run")
			_lower_body.play("run")
		if direction == -1:
			_lower_body.scale.x = -1
		else:
			_lower_body.scale.x = 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			_upper_body.play("default")
			_lower_body.play("default")
	move_and_slide()

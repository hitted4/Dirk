extends Node2D
var DEBUGGING = true
var game_window: Rect2 # Game window

# World emits signal when joystick connects.
signal disconnected
signal connected

# Parent sets `num_players` based on number of connected joysticks.
# Parent adjusts `num_players` when number of connected joysticks
# changes.
#
# JOYSTICK DEVICE NUMBER:
# `range(num_players)` creates a sequence of numbers.
# The sequence has length `num_players` and starts at 0.
# -> This sequence matches the joystick device number when
# joysticks are attached:
# first  joystick is device 0,
# second joystick is device 1, etc.
#
# TESTING:
# Hardcode `num_players` to test `World.tscn` without a Parent.
# -> When the parent writes to `num_players`, it overrides the
# value here in `World.gd`.
@export var num_players: int# number of joysticks connected

var players: Array = [] # array to hold player instances
var input_maps: Array = [] # array to hold input_map dict for each player


var rng = RandomNumberGenerator.new()

# Load the Player scene
const player_scene = preload("res://Scenes/PlayerCharacter/dirk.tscn")

# _draw() runs once, sometime shortly after _ready() runs
# TODO: why is their a delay in responding to motion input when
# DEBUGGING_GRID = true?
var DEBUGGING_GRID = true


# TEMPORARY FIX FOR USING KEYBOARD
@onready var use_keyboard: bool = false

func _ready() -> void:
	# Inherit parent.DEBUGGING if this scene is not the entry point.
	preload("res://Scenes/PlayerCharacter/dirk.tscn")
	var parent_node: Node = get_parent()
	if parent_node.name != "root":
		DEBUGGING = parent_node.DEBUGGING

	game_window = get_viewport_rect()

	if DEBUGGING:
		print("Running {n}._ready()... Connected players {j}".format({
			"n": name,
			"j": num_players,
			}))
		# Report scene hierarchy.
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
			}))


	# Seed a random number generator for positioning blocks.
	rng.randomize() # setup the generator from a time-based seed

	# Add players to match number of connected joysticks. Parent
	# sets `num_players` based on number of connected joysticks.
	# If no parent, default to 4 joysticks for testing.
	if use_keyboard:
		num_players = 4
	for player_index in range(num_players):
		add_player(player_index)
	
	# TEMPORARY FIX FOR USING KEYBOARD
#	if num_players == 0:
#		use_keyboard = true
#		# for player_index in range(1):
#		for player_index in range(4):
#			add_player(player_index)




# func gridlines() -> void:
# 	# Draw grid lines
# 	# Define the endpoints.
# 	# PLACEHOLDER:
# 	draw_line(
# 		Vector2(20,100), # from
# 		Vector2(20,800), # to
# 		ColorN("magenta", 1) # color
# 		)





func spawn_position(player_index) -> Vector2:
	var marker: Node2D = get_child(player_index+1)
	var random_tile: Vector2 = marker.position
	return random_tile




func remove_player(player_index: int) -> void:
	# TODO: Remove the player. Or show in some way that the
	# player is inactive.
	# For now I leave the disconnected player on screen and
	# do nothing. The player is technically still "in play" and
	# other players can interact with it. But the player cannot
	# be controlled because the joystick is disconnected.
	# When the joystick reconnects, control is restored.
	emit_signal("disconnected", players[player_index].player_name)


func add_player(player_index: int) -> void:
	# Add a player to the game.
	# `player_index` is the player's index in array `players`.
	# `player_index` is also the player's joystick device number.

	# First handle the corner case:
	# If a player disconnects and reconnects, the World already
	# knows about them. They are not a "new" player.
	# There information is still in the `players` array.
	# Therefore, instead of initializing like a "new" player, we
	# just want to revive this player.
	#
	# To catch this corner case, check if the player is "new".
	# The player is new if player_index == number of players so far.
	# If player_index is < number of players so far, this is an
	# "old" player. Even if the last player to join leaves the
	# game, the number of 
	if player_index < players.size():
		# TODO: add code to revive old player.
		# I'll need to "revive" once I've coded "removal."
		# For now I leave the disconnected player on screen and
		# do nothing, so there is nothing to do to "revive" the
		# player. They reconnect their joystick and they can move
		# again.
		# TODO: change to property "player.connected" and
		# `Player` should be the one to interpret this as a
		# change in alpha. `World` should not know how `Player`
		# visualizes itself with `Block`.
		emit_signal("connected", players[player_index].player_name)
		return
	

	# Instantiate a new player.
	# Append the player instance to array `players`.
	players.append(player_scene.instantiate())

	# Refer to this just-added player as "player" for readability.
	var player = players[-1]

	# Randomize player's starting x,y position.


	player.start_position = spawn_position(player_index)
	player.player_id = player_index
	player.use_keyboard=use_keyboard

	# TODO: index at random into the list of colors so that I'm
	# not limited to 4 players.
	# TODO: let players change their color before the game begins.
	var colornames: Array = [
		"pink",
		"lightblue",
		"yellow",
		"lightsalmon",
		]
	var colors: Array = [
		Color(1, 0.270588, 0, 1),
		Color(0.678431, 0.847059, 0.901961, 1),
		Color(1, 1, 0, 1),
		Color(1, 0.627451, 0.478431, 1),
	]
	# DEBUGGING COLLSIONS: Debug -> Visible Collision Shapes
	# alpha < 1 to see Player's Area2D.
	var _alpha = 1.0 # build
	# var alpha = 0.3 # debug
	# TODO: Why a dict? Make this an Array.
	player.color = colors[player_index]
	
	
	# Identify players by their color.
	player.player_name = colornames[player_index]

	# SETUP COLLISION RESPONSES
	# (`connect()` returns 0: throw away return value in a '_var')
	

	# Create an input_map dict for this player's joystick/keyboard.
	input_maps.append({
		"move_right_{n}".format({"n":player_index}): Vector2.RIGHT,
		"move_left_{n}".format({"n":player_index}): Vector2.LEFT,
		"move_up_{n}".format({"n":player_index}): Vector2.UP,
		"move_down_{n}".format({"n":player_index}): Vector2.DOWN,
		"jump_{n}".format({"n":player_index}): Vector2.UP,
		"aim_{n}".format({"n":player_index}): Vector2.ZERO
		})
		# DEBUGGING
		# print(input_maps[player_index])
	
	# Assign the input_map to this player.
	player.ui_inputs = input_maps[player_index]

	if not use_keyboard:
		# Use controllers
		# Assign the joystick device number to this player.
		# (`player_index` is the player's joystick device number.)
		player.device_num = player_index


		# Edit the InputMap to match the names used in the input_map assignments.
		# For example, default InputMap has name "ui_left".
		# I use the same default names but with a device number suffix.
		# So "ui_left" becomes "ui_left0", "ui_left1", etc.
		# These are called "actions". The joypad motion that triggers
		# the action is called an "action event".

		# CODE:
		# I create the String and the InputEventJoypadMotion in a
		# for loop so that there are unique instances of each.
		#
		# -> If I defined the InputEventJoypadMotion *outside* the
		# for loop, then there is only one instance is in memory.
		# Each time I updated this instance with settings for the
		# next player, the previous players are still "looking" at
		# that same instance, so by the end of the loop, all players
		# are controlled by the last controller connected. No good.
		#
		# For readability, I make variables to temporarily point to
		# the String that identifies the "action" and the
		# InputEventJoypadMotion that defines the "action event".
		# Also, I don't know how to set properities in the `new()`
		# method, so I need a variable to refer back to the
		# InputEventJoypadMotion to set its properties.

		var right_action: String
		var right_action_event: InputEventJoypadMotion

		var left_action: String
		var left_action_event: InputEventJoypadMotion

		var up_action: String
		var up_action_event: InputEventJoypadMotion

		var down_action: String
		var down_action_event: InputEventJoypadMotion
		
		var jump_action: String
		var jump_action_event: InputEventJoypadButton
		
		var aim_action: String
		var aim_action_event: InputEventJoypadMotion

		right_action = "move_right_{n}".format({"n":player_index})
		InputMap.add_action(right_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		right_action_event = InputEventJoypadMotion.new()
		right_action_event.device = player_index
		right_action_event.axis = JOY_AXIS_LEFT_X # <---- horizontal axis
		right_action_event.axis_value =  1.0 # <---- right
		InputMap.action_add_event(right_action, right_action_event)

		left_action = "move_left_{n}".format({"n":player_index})
		InputMap.add_action(left_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		left_action_event = InputEventJoypadMotion.new()
		left_action_event.device = player_index
		left_action_event.axis = JOY_AXIS_LEFT_X # <---- horizontal axis
		left_action_event.axis_value = -1.0 # <---- left
		InputMap.action_add_event(left_action, left_action_event)

		up_action = "move_up_{n}".format({"n":player_index})
		InputMap.add_action(up_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		up_action_event = InputEventJoypadMotion.new()
		up_action_event.device = player_index
		up_action_event.axis = JOY_AXIS_LEFT_Y # <---- vertical axis
		up_action_event.axis_value = -1.0 # <---- up
		InputMap.action_add_event(up_action, up_action_event)

		down_action = "move_down_{n}".format({"n":player_index})
		InputMap.add_action(down_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		down_action_event = InputEventJoypadMotion.new()
		down_action_event.device = player_index
		down_action_event.axis = JOY_AXIS_LEFT_Y # <---- vertical axis
		down_action_event.axis_value =  1.0 # <---- down
		InputMap.action_add_event(down_action, down_action_event)
		
		jump_action = "jump_{n}".format({"n":player_index})
		InputMap.add_action(jump_action)
		jump_action_event = InputEventJoypadButton.new()
		jump_action_event.device = player_index
		jump_action_event.button_index = JOY_BUTTON_A
		InputMap.action_add_event(jump_action, jump_action_event)
		

	else:
		# Use keyboard
		# Map to keys for four people on one keyboard.
		var arrows: Dictionary = {
			"key_right": KEY_RIGHT,
			"key_left":  KEY_LEFT,
			"key_up":    KEY_UP,
			"key_down":  KEY_DOWN,
			}
		var wasd: Dictionary = {
			"key_right": KEY_D,
			"key_left":  KEY_A,
			"key_up":    KEY_W,
			"key_down":  KEY_S,
			}
		var hjkl: Dictionary = {
			"key_right": KEY_L,
			"key_left":  KEY_H,
			"key_up":    KEY_K,
			"key_down":  KEY_J,
			}
		var uiop: Dictionary = {
			"key_right": KEY_P,
			"key_left":  KEY_U,
			"key_up":    KEY_O,
			"key_down":  KEY_I,
			}
		var keymaps: Dictionary = {
			0: arrows,
			1: wasd,
			2: hjkl,
			3: uiop,
			}

		var right_action: String
		var right_action_event: InputEventKey

		var left_action: String
		var left_action_event: InputEventKey

		var up_action: String
		var up_action_event: InputEventKey

		var down_action: String
		var down_action_event: InputEventKey
		
		var jump_action: String
		var jump_action_event: InputEventKey
		

		right_action = "move_right_{n}".format({"n":player_index})
		InputMap.add_action(right_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		right_action_event = InputEventKey.new()
		right_action_event.keycode = keymaps[player_index]["key_right"]
		InputMap.action_add_event(right_action, right_action_event)

		left_action = "move_left_{n}".format({"n":player_index})
		InputMap.add_action(left_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		left_action_event = InputEventKey.new()
		left_action_event.keycode = keymaps[player_index]["key_left"]
		InputMap.action_add_event(left_action, left_action_event)

		up_action = "move_up_{n}".format({"n":player_index})
		InputMap.add_action(up_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		up_action_event = InputEventKey.new()
		up_action_event.keycode = keymaps[player_index]["key_up"]
		InputMap.action_add_event(up_action, up_action_event)

		down_action = "move_down_{n}".format({"n":player_index})
		InputMap.add_action(down_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		down_action_event = InputEventKey.new()
		down_action_event.keycode = keymaps[player_index]["key_down"]
		InputMap.action_add_event(down_action, down_action_event)
		
		jump_action = "jump_{n}".format({"n":player_index})
		InputMap.add_action(jump_action)
		jump_action_event = InputEventKey.new()
		jump_action_event.keycode = keymaps[player_index]["key_up"]
		InputMap.action_add_event(jump_action, jump_action_event)

	# FINALLY: Now that player is all set up,
	# make the player a child node of the World scene
	add_child(player)




# Broadcast when one player hits another.
signal player_hit


func _on_hit(victim_name, collision_normal) -> void:
	emit_signal("player_hit", victim_name, collision_normal)

func _on_double_hit(player_name, player_direction) -> void:
	# Both players report. I only need one player_name from each.
	# Player direction is known from keypress.
	# If no key is pressed, expect Player sends a random value.
	emit_signal("player_hit", player_name, player_direction)
	if DEBUGGING:
		print("Double Hit!")


func _on_desert_level_body_entered(body):
	body.respawn()

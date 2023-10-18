extends Node2D
var DEBUGGING = true
var world: Resource
var connected_joypads: int = 0
var world_instance

# Called when the node enters the scene tree for the first time.
func _ready():
	if DEBUGGING:
		print("Running {n}._ready()... connected joypads: {j}".format({
			"n":name,
			"j": Input.get_connected_joypads()
			}))
		# Report scene hierarchy.
		print("Parent of '{n}' is '{p}' (Expect 'root')".format({
			"n":name,
			"p":get_parent().name,
			}))
	world = preload("res://Scenes/world.tscn")
	world_instance = world.instantiate()
	add_child(world_instance)
	connected_joypads = Input.get_connected_joypads().size()
	world_instance.num_players = connected_joypads
	
	
	var _ret: int # '_' in _var tells GDScript unused var is OK
	_ret = Input.joy_connection_changed.connect(_on_joy_connection_changed)
	if _ret != 0:
		print("Error {e} connecting `Input` signal `joy_connection_changed`.".format({"e": _ret}))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if DEBUGGING:
		if connected:
			print("Connected device {d}.".format({"d":device}))
		else:
			print("Disconnected device {d}.".format({"d":device}))
	if connected:
		# Update number of players to number of connected joysticks.
		world_instance.num_players = Input.get_connected_joypads().size()

		# Add the player to the world. Use the device number as
		# the player index into the array of players.
		world_instance.add_player(device)
		print("Added player index {d} to the world.".format({"d":device}))

	else:
		# Do not change the number of players when a player disconnects.
		# There is a chance the disconnected player wins the round.

		world_instance.remove_player(device)
		print("Removed player index {d} from the world.".format({"d":device}))

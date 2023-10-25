extends Node2D
var use_keyboard: bool
var mpos =Vector2()
var pos = Vector2()
var _lookdir = Vector2()
var player_id: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if use_keyboard:
		look_at(get_global_mouse_position())
		if rotation_degrees > 180:
			rotation_degrees = -180
		if rotation_degrees < -180:
			rotation_degrees = 180
	else:
		_lookdir.y= Input.get_joy_axis(player_id, JOY_AXIS_RIGHT_Y)
		_lookdir.x= Input.get_joy_axis(player_id, JOY_AXIS_RIGHT_X)
		rotation = _lookdir.angle()
	$AnimatedSpriteUpper.rad = rotation
	

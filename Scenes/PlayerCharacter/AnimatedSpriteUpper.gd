extends AnimatedSprite2D
var use_keyboard: bool
var player_id
var _lookdir: Vector2
var rot
var rad
func keyboard_set(keyboard):
	use_keyboard = keyboard

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	rot = rad_to_deg(rad)
	if rot >= -90 && rot <= 90:
		self.flip_v = false
		offset.y = 0
	else:
		self.flip_v = true
		offset.y = 10
		
	

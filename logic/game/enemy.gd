extends RigidBody2D
class_name Enemy

var speed_base_coef = 50;
@export var speed : float = 10;

var was_kicked : bool = false;
var elastic_vector = Vector2.ZERO
var first_elastic_vector = Vector2.ZERO
var is_stun = false

var going_in = false
var going_out = false

var target;

# Called when the node enters the scene tree for the first time.
func _ready():
	target = GameManager.player;
	pass # Replace with function body.

func receive_kick(kick_force):
	if is_stun:
		die();
	else:
		$Sprite2D.self_modulate = Color.WEB_GREEN
		apply_impulse(kick_force)
		is_stun = true
		GameManager.elastic.add(self)

func die():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if not is_stun:
		var motion_intention = target.position - position;
		motion_intention = motion_intention.normalized();
		linear_velocity = motion_intention * speed_base_coef * speed;
	
	if is_stun and elastic_vector != Vector2.ZERO and not going_out:
		going_in = true
		going_out = false
	
	var vspeed = linear_velocity.length()
	
	if is_stun and elastic_vector != Vector2.ZERO and vspeed == 0:
		going_out = true
		going_in = false
	
	if elastic_vector == Vector2.ZERO:
		going_out = false
		going_in = false
	
	var line = $Line2D
	line.set_point_position(1, elastic_vector.normalized()*100)
	
	if going_in:
		vspeed = max(0, vspeed - 10)
		linear_velocity = linear_velocity.normalized() * vspeed
	elif going_out:
		linear_velocity += elastic_vector.normalized() * 10
	
#	print(going_in, ' ', going_out)
	

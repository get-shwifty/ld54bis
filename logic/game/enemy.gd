extends RigidBody2D
class_name Enemy

var speed_base_coef = 50;
@export var speed : float = 10;

var was_kicked : bool = false;
var elastic_vector = Vector2.ZERO
var first_elastic_vector = Vector2.ZERO
var is_stun = false

var target;

# Called when the node enters the scene tree for the first time.
func _ready():
	target = GameManager.player;
	pass # Replace with function body.

func receive_kick(kick_force):
	apply_impulse(kick_force)
	is_stun = true
	GameManager.elastic.add(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if not is_stun:
		var motion_intention = target.position - position;
		motion_intention = motion_intention.normalized();
		linear_velocity = motion_intention * speed_base_coef * speed;
	
	return
	if is_stun and elastic_vector != Vector2.ZERO:
		if first_elastic_vector == Vector2.ZERO:
			first_elastic_vector = elastic_vector
		linear_velocity += first_elastic_vector.normalized() * 20
	

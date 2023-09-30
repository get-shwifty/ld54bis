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
	
	if is_stun and elastic_vector != Vector2.ZERO:
		var line = $Line2D
#		if first_elastic_vector == Vector2.ZERO:
#			first_elastic_vector = elastic_vector
#			line.set_point_position(1, elastic_vector.normalized() * 100)

#		linear_velocity += elastic_vector.normalized() * 20
		var speed = linear_velocity.length()
		speed = max(0, speed - 10)
		if speed > 0:
#			print(abs(elastic_vector.angle_to(-linear_velocity)))
			linear_velocity = linear_velocity.normalized() * speed
		else:
			linear_velocity += elastic_vector.normalized() * 100
	

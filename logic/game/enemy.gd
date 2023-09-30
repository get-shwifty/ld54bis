extends RigidBody2D
class_name Enemy

var was_kicked : bool = false;
var elastic_vector = Vector2.ZERO
var first_elastic_vector = Vector2.ZERO
var is_stun = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func receive_kick(kick_force):
	apply_impulse(kick_force)
	is_stun = true
	GameManager.elastic.add(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if is_stun and elastic_vector != Vector2.ZERO:
		var line = $Line2D
#		if first_elastic_vector == Vector2.ZERO:
#			first_elastic_vector = elastic_vector
#			line.set_point_position(1, elastic_vector.normalized() * 100)

#		linear_velocity += elastic_vector.normalized() * 20
		var speed = linear_velocity.length()
		speed = max(0, speed - 10)
		if speed > 0:
			print(abs(elastic_vector.angle_to(-linear_velocity)))
			linear_velocity = linear_velocity.normalized() * speed
		else:
			linear_velocity += elastic_vector.normalized() * 100
	

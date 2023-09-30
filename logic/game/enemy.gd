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
	linear_velocity = kick_force;
	is_stun = true
	GameManager.elastic.add(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	return
	if is_stun and elastic_vector != Vector2.ZERO:
		if first_elastic_vector == Vector2.ZERO:
			first_elastic_vector = elastic_vector
		linear_velocity += first_elastic_vector.normalized() * 20
	

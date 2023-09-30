extends RigidBody2D
class_name Enemy

var was_kicked : bool = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func receive_kick(kick_force):
	linear_velocity = kick_force;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

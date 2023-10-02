extends Node2D

var elastic_vector = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_core_position():
	return $LightEmitionPosition.global_position;

func get_shader_materials():
	return [$AnimatedSprite2D.get_material(), $Sprite2D.get_material()];

func get_reference_velocity():
	return Vector2.ZERO;

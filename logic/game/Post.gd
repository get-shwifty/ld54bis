extends Node2D

@onready var sprt : AnimatedSprite2D = $Sprite2D
@onready var lifetime :Timer = $LifetimeTimer

@export var LIFETIME_DURATION = 5;

var elastic_vector = Vector2.ZERO
var mobile = false
var unload = false

# Called when the node enters the scene tree for the first time.
func _ready():
	lifetime.start();
	sprt.play("default")
	await sprt.animation_finished
	unload = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if unload:
		var lifetime_ratio = lifetime.time_left / lifetime.wait_time;
		var frame = floor(lifetime_ratio * 8)
		sprt.frame = frame
#	sprt.scale = Vector2(lifetime_ratio, lifetime_ratio);
	
	if mobile and (elastic_vector == Vector2.ZERO or GameManager.elastic.size < 100):
		queue_free()
		return

	if mobile:
		print(elastic_vector)
		visible = false
		var dir = elastic_vector.normalized() * 5
		global_position = Vector2(global_position.x + dir.x, global_position.y + dir.y)


func get_shader_materials():
	return [$Sprite2D.get_material()]

func get_reference_velocity():
	return Vector2.ZERO

func _on_lifetime_timer_timeout():
	mobile = true;
#	await get_tree().create_timer(2.0).timeout
#	queue_free()

extends Node2D

@onready var sprt : Sprite2D = $Sprite2D
@onready var lifetime :Timer = $LifetimeTimer

@export var LIFETIME_DURATION = 15;

var elastic_vector = Vector2.ZERO
var mobile = false

# Called when the node enters the scene tree for the first time.
func _ready():
	lifetime.start();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var lifetime_ratio = lifetime.time_left / lifetime.wait_time;
	sprt.scale = Vector2(lifetime_ratio, lifetime_ratio);
	
	if mobile and elastic_vector == Vector2.ZERO:
		queue_free()
		return
	
	if mobile:
		visible = false
		var dir = elastic_vector.normalized() * 40
		global_position = Vector2(global_position.x + dir.x, global_position.y + dir.y)




func _on_lifetime_timer_timeout():
	mobile = true;

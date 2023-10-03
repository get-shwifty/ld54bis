extends Node2D

var elastic_vector = Vector2.ZERO
var is_off = false
var is_turning_off = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("on")
	GameManager.core = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameManager.elastic.post_count == 0:
		turn_off()
	elif not is_off:
		$AnimatedSprite2D.play("on")
		is_turning_off = false

func get_core_position():
	return $LightEmitionPosition.global_position;

func get_shader_materials():
	return [$AnimatedSprite2D.get_material(), $Sprite2D.get_material()];

func get_reference_velocity():
	return Vector2.ZERO;
	
func turn_off():
	if is_turning_off:
		return
	is_turning_off = true
	$AnimatedSprite2D.play("blink")
	await get_tree().create_timer(2.0).timeout
	if GameManager.elastic.post_count == 0:
		is_off = true
		GameManager.level_manager.drop_mobile_post(global_position)
		$AnimatedSprite2D.play("off")
		GameManager.elastic.remove(self)
	else:
		is_turning_off = false

func hit(damage):
	damage /= 10;
	GameManager.player.hit_internal(damage, true);

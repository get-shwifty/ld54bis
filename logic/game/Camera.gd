extends Camera2D
class_name GameCamera

var shake_strength:float = 0.0


var hit_shake: bool = false
var shoot_shake: bool = false

@export var SHOOT_DECAY_RATE:float = 3.0
@export var SHOOT_STRENGHT:int = 20

@export var HIT_STRENGTH:float = 4.0
@export var HIT_DECAY_RATE:float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.camera = self


func shake_on_shoot(direction: Vector2):
	offset = direction * SHOOT_STRENGHT
	shoot_shake = true

func shake_on_hit():
	hit_shake = true
	shake_strength += HIT_STRENGTH
#
func get_random_offset() -> Vector2:
	return Vector2(
		randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength)
	)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shoot_shake:
		offset = lerp(offset, Vector2(), SHOOT_DECAY_RATE * delta)
		if offset == Vector2():
			shoot_shake = false
	if hit_shake:
		shake_strength = lerp(shake_strength, 0.0, HIT_DECAY_RATE * delta)
		offset = get_random_offset()
		if shake_strength == 0:
			hit_shake = false

extends RigidBody2D
class_name BaseEnemy

enum STATE { MOVE, STUN }
var state: STATE = STATE.MOVE

# move
@export var FORCE_SPEED = 200
@export var MAX_SPEED = 50

# stun
@onready var stun_timer : Timer = $StunTimer

# death
@onready var death_timer : Timer = $DeathTimer

@export var damage = 10

# target
var target


var was_kicked : bool = false;
var elastic_vector = Vector2.ZERO
var first_elastic_vector = Vector2.ZERO
var is_stun = false
var is_dead = false

var going_in = false
var going_out = false

var elastic_decel = 50
var elastic_accel = 100

var cur_action_index = -1

func _ready():
	target = GameManager.player
	$Animation.play("default")

func receive_kick(action_idx, kick_force):
	if cur_action_index == action_idx:
		return
	else:
		cur_action_index = action_idx

	if state == STATE.STUN:
		apply_impulse(kick_force/2)
		die()
		return

	state = STATE.STUN
	stun_timer.start()
	
	$Animation.self_modulate = Color.WEB_GREEN
	GameManager.elastic.add(self)
	
	linear_velocity = Vector2.ZERO
	apply_impulse(kick_force)

func die():
	is_dead = true
	death_timer.start()
	
func _physics_process(delta):
	var vspeed = linear_velocity.length()
	
	match state:
		STATE.MOVE:
			var motion_intention = target.global_position - global_position
			motion_intention = motion_intention.normalized()
			var err = max(0, MAX_SPEED - vspeed)
			apply_force(motion_intention * err * FORCE_SPEED)
		STATE.STUN:
			# going in/out
			if elastic_vector != Vector2.ZERO:
				if not going_out:
					going_in = true
					going_out = false
				if vspeed == 0:
					going_out = true
					going_in = false
			else:
				going_out = false
				going_in = false
			
			var line = $Line2D
			line.set_point_position(1, elastic_vector.normalized()*100)
			
			if going_in:
				vspeed = max(0, vspeed - elastic_decel * (1+GameManager.elastic.resistance*8))
				linear_velocity = linear_velocity.normalized() * vspeed
			elif going_out:
				linear_velocity += elastic_vector.normalized() * elastic_accel * (1+GameManager.elastic.resistance*8)
	
func _on_death_timer_timeout():
	GameManager.level_manager.spawn_coin(global_position, linear_velocity)
	GameManager.level_manager.drop_mobile_post(position)
	queue_free()

func _on_stun_timer_timeout():
	state = STATE.MOVE
	$Animation.self_modulate = Color.WHITE
	GameManager.elastic.remove(self)

func get_reference_velocity():
	return linear_velocity

func get_shader_material():
	return $Animation.get_material()
	
func _on_damage_box_area_entered(area):
	var player = area.get_parent()
	player.hit(damage)

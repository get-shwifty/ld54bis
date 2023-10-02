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
var can_damage = true

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
	GameManager.add_score(self, 100)
	$DamageBox.monitoring = false
	collision_mask = 4
	stun_timer.start()
	
	$Animation.self_modulate = Color.WEB_GREEN
	GameManager.elastic.add(self)
	
	linear_velocity = Vector2.ZERO
	apply_impulse(kick_force)

func die():
	GameManager.add_score(self, 500)
	is_dead = true
	death_timer.start()
	
func _physics_process(delta):
	var vspeed = linear_velocity.length()
	
	var is_inside = GameManager.elastic.is_inside(global_position)
	$Ombre.visible = is_inside
	$Animation.visible = is_inside
	$InShadowAnimation.visible = not is_inside
	match state:
		STATE.MOVE:
			var motion_intention = target.global_position - global_position
			motion_intention = motion_intention.normalized()
			var err = max(0, MAX_SPEED - vspeed)
			apply_force(motion_intention * err * FORCE_SPEED)
			try_damage_player()
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
	var prob = randf()
	if prob > 0.9:
		GameManager.level_manager.spawn_coin(global_position, linear_velocity)
	GameManager.level_manager.drop_mobile_post(position)
	queue_free()

func _on_stun_timer_timeout():
	state = STATE.MOVE
	$DamageBox.monitoring = true
	collision_mask = 7
	$Animation.self_modulate = Color.WHITE
	GameManager.elastic.remove(self)

func get_reference_velocity():
	return linear_velocity

func get_shader_materials():
	return [$Animation.get_material(), $InShadowAnimation.get_material()]
	
func try_damage_player():
	if not can_damage and $DamageTimer.is_stopped():
		$DamageTimer.start()
		
	if not can_damage:
		return
	
	var areas = $DamageBox.get_overlapping_areas()
	for area in areas:
		var player = area.get_parent()
		player.hit(damage)
		can_damage = false

func _on_damage_timer_timeout():
	can_damage = true

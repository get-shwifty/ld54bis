extends "./base_enemy.gd"

# same as dumb but can dodge

@export var stop_at = 40
@export var attack_at = 50
@export var attack_duration = 250
@export var attack_cooldown = 2000
@export var dodge_duration = 150
@export var dodge_cooldown = 3000
@export var dodge_impulse = 800

var last_time_attack = 0
var attacking = false
var last_time_dodge = 0
var dodge = false

func move_process(delta):
	var now = Time.get_ticks_msec()
	
	if dodge and now - last_time_dodge > dodge_duration:
		dodge = false
		hook_stun()
	if dodge:
		return
		
	
	var distance_to_target = target.global_position.distance_to(global_position)
	var can_attack1 = distance_to_target < attack_at
	var can_attack2 = last_time_attack < (now - attack_cooldown)
	if attacking or (can_attack1 and can_attack2):
		# attack
		if not attacking:
			attacking = true
			last_time_attack = now
		elif now - last_time_attack > attack_duration:
			attacking = false
			last_time_attack = now
		force_speed = 50
		max_speed = 150
		apply_force(get_force_to(target.global_position))
		try_damage_player() # better here?
	else:
		# move to target
		force_speed = 10
		max_speed = 100
		var dir = target.global_position.direction_to(global_position)
		var stop_pos = target.global_position + dir * stop_at
		apply_force(get_force_to(stop_pos))


func _on_player_dodge_body_entered(body):
	var now = Time.get_ticks_msec()
	if now - last_time_dodge < dodge_cooldown:
		return

	if body.velocity.length() > 100:
		var dir = body.global_position.direction_to(global_position)
		if body.velocity.dot(dir) > 100:
			var sign = 1 if body.velocity.angle_to(dir) > 0 else -1
			dodge = true
			last_time_dodge = now
			var dodge_dir = dir.rotated(deg_to_rad(90*sign))
			modulate.a = 0.5
			collision_mask = 0
			apply_impulse(dodge_dir * dodge_impulse)

func hook_stun():
	last_time_dodge = Time.get_ticks_msec()
	modulate.a = 1
	collision_mask = 3

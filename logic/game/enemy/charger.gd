extends "./base_enemy.gd"

@export var stop_at = 130
@export var attack_at = 100
@export var attack_duration = 1250
@export var attack_cooldown = 5000

var last_time_attack = 0
var attacking = false

func move_process(delta):
	var now = Time.get_ticks_msec()
	
	var can_attack1 = target.global_position.distance_to(global_position) < attack_at
	var can_attack2 = last_time_attack < (now - attack_cooldown)
	if attacking or (can_attack1 and can_attack2):
		# attack
		if not attacking:
			attacking = true
			last_time_attack = now
			$Animation.play("charge")
		elif now - last_time_attack > attack_duration:
			attacking = false
			last_time_attack = now
			$Animation.play("default")
		force_speed = 50
		max_speed = 200
		apply_force(get_force_to(target.global_position))
		try_damage_player() # better here?

	if not attacking:
		# move to target
		force_speed = 10
		max_speed = 100
		var dir = target.global_position.direction_to(global_position)
		var stop_pos = target.global_position + dir * stop_at
		apply_force(get_force_to(stop_pos))

	if linear_velocity.x != 0:
		$Animation.flip_h = linear_velocity.x > 0

func hook_stun():
	$Animation.play("default")
	

extends CharacterBody2D

enum STATE { MOVE, KICK, DASH }
var state: STATE = STATE.MOVE

var next_state: STATE = STATE.MOVE
@export var NEXT_STATE_TIMING_MS = 100

var action_idx = 0

# move
var move_intention: Vector2 = Vector2.ZERO
var orientation: Vector2 = Vector2.ZERO

# kick
@onready var kick_node = $kick
@onready var kick_node_pos = kick_node.position
var kick_direction: Vector2 = Vector2.ZERO
var kick_start_time = 0
@export var KICK_TIME_MS = 45
@export var KICK_FORCE = -300
@export var KICK_COEFF = 0.3

# dash
var dash_direction: Vector2 = Vector2.ZERO
var dash_start_time = -1e6
var after_images_pos = []
@export var DASH_TIME_MS = 200
@export var DASH_FORCE = 1000
@export var DASH_MAX_SPEED = 10
@export var DASH_COEFF = 0.2
@export var DASH_COOLDOWN_MS = 100

# elastic
@export var max_total_speed = 2000
var elastic_vector = Vector2.ZERO
var elastic_velocity = Vector2.ZERO
var elastic_drag = 200
var elastic_power = 300
var is_pulling = false
var dash_bounce_vector = Vector2.ZERO
var elastic_kick_speed = 300

const move_base_coef = 50
@export var move_max_speed : float = 4


@export var kick_force : float = 1000

@export var drop_post_offset: float = 1
@export var post_bag_size = 3
@onready var post_nb = post_bag_size

#hp
@export var max_hp = 100
@onready var hp = max_hp

func _ready():
	GameManager.player = self;


func _physics_process(delta):
	update_move_intention()
	process_orientation(delta)
	
	match state:
		STATE.MOVE:
			$HitBox.monitorable = true
			velocity = get_move_velocity()
			if velocity == Vector2.ZERO:
				$SpritePersonnage.play("iddle")
			else:
				$SpritePersonnage.play("walk")
			check_next_state()
			match next_state:
				STATE.KICK:
					kick()
				STATE.DASH:
					dash()
			next_state = STATE.MOVE # reset next_state

			if Input.is_action_just_pressed("game_drop_post"):
				drop_post(position + orientation * drop_post_offset)
		STATE.KICK:
			$HitBox.monitorable = false
			kick_state(delta)
		STATE.DASH:
			$HitBox.monitorable = false
			dash_state(delta)

	elastic_movement()
	move_and_slide()
#	print(after_images_pos)
	for i in range(len(after_images_pos)):
		var child = $AfterImages.get_children()[i]
		child.global_position = after_images_pos[i]
		child.self_modulate.a *= 0.8

func hit(dmg):
	if state != STATE.DASH:
		hp -= dmg
		$HitSoundPlayer.play(0.0);
		if hp <= 0:
			GameManager.no_hp_game_over()

func set_state(new_state):
	state = new_state
	action_idx += 1

func check_next_state():
	if Input.is_action_just_pressed("game_kick"):
		next_state = STATE.KICK
	elif Input.is_action_just_pressed("game_dash"):
		var last_dash = dash_start_time + DASH_TIME_MS
		if (Time.get_ticks_msec() - last_dash) > DASH_COOLDOWN_MS:
			next_state = STATE.DASH

func process_orientation(delta):
#	var mouse_pos : Vector2 = get_global_mouse_position()
	if move_intention != Vector2.ZERO:
		orientation = move_intention
	var angle = orientation.angle()
	kick_node.position = kick_node_pos.rotated(angle)
	kick_node.rotation = angle

func get_move_velocity():
	return move_intention * move_max_speed * move_base_coef

func update_move_intention():
	move_intention = Vector2.ZERO
	
	if Input.is_action_pressed("game_right"):
		move_intention.x += 1
		$SpritePersonnage.flip_h = true
	if Input.is_action_pressed("game_left"):
		move_intention.x -= 1
		$SpritePersonnage.flip_h = false
	if Input.is_action_pressed("game_down"):
		move_intention.y += 1
	if Input.is_action_pressed("game_up"):
		move_intention.y -= 1
	
	move_intention = Input.get_vector("game_left", "game_right", "game_up", "game_down")
	if move_intention.x < 0:
		$SpritePersonnage.flip_h = false
	else:
		$SpritePersonnage.flip_h = true
#	move_intention = move_intention.normalized()

func check_kick():
	var enemies_to_kick = $kick/KickArea.get_overlapping_bodies()
	for enemy in enemies_to_kick:
		enemy = enemy as BaseEnemy
		enemy.receive_kick(action_idx, orientation * kick_force)

func kick_state(delta):
	var delta_time_kick = Time.get_ticks_msec() - kick_start_time
	$kick/Explosion.visible = true
	$kick/Explosion.play("default")
	if delta_time_kick > KICK_TIME_MS:
		set_state(STATE.MOVE)
		return
	elif delta_time_kick > (KICK_TIME_MS - NEXT_STATE_TIMING_MS):
		check_next_state()

	var coeff = float(delta_time_kick) / KICK_TIME_MS
	coeff = -pow(coeff, KICK_COEFF)
	velocity = get_move_velocity()
	velocity += kick_direction * coeff * KICK_FORCE

func kick():
	if state == STATE.MOVE:
		set_state(STATE.KICK)
		$KickSoundPlayer.play(0.0)
		kick_direction = orientation
		kick_start_time = Time.get_ticks_msec()
		check_kick()

func dash_state(delta):
	var delta_time_dash = Time.get_ticks_msec() - dash_start_time
	if delta_time_dash > DASH_TIME_MS:
		set_state(STATE.MOVE)
		return
	elif delta_time_dash > (DASH_TIME_MS - NEXT_STATE_TIMING_MS):
		check_next_state()

	var coeff = float(delta_time_dash) / DASH_TIME_MS
	coeff = pow(coeff, DASH_COEFF)
	velocity = dash_direction * coeff * DASH_FORCE
	velocity = velocity.limit_length(DASH_MAX_SPEED / delta)

func dash():
	if state == STATE.MOVE:
		set_state(STATE.DASH)
		dash_direction = orientation
		dash_start_time = Time.get_ticks_msec()
		after_images_pos.clear()
		for after_image in $AfterImages.get_children():
			after_image.visible = true
			after_image.global_position = global_position
			after_image.self_modulate.a = 0.8
			after_images_pos.append(global_position)
			await get_tree().create_timer(0.05).timeout
		var children = $AfterImages.get_children()

		
func end_pull():
	if is_pulling:
		pass
#		print('end pull')
	is_pulling = false

var old_vel = Vector2.ZERO
func elastic_movement():
	var m_speed = move_max_speed * move_base_coef
	var mark_as_out = false
	if velocity != Vector2.ZERO:
		elastic_velocity = Vector2.ZERO
	
	if elastic_vector != Vector2.ZERO:
		var resistance = GameManager.elastic.resistance
		var q_res = min(1, resistance) ** 8
		var dot = velocity.dot(elastic_vector)

		if velocity != Vector2.ZERO && dot < 0:
#			print('manual pull')
			if state == STATE.DASH and dash_bounce_vector == Vector2.ZERO:
				var delta_time_dash = Time.get_ticks_msec() - dash_start_time
				var coeff = float(delta_time_dash) / DASH_TIME_MS
				dash_bounce_vector = -velocity * (1-coeff)
			is_pulling = true
			var velocity_counter = -velocity * resistance
			var elastic_counter = elastic_vector.normalized() * m_speed
			elastic_velocity = (1 - q_res) * velocity_counter + q_res * elastic_counter
		else:
#			print('go out')
			mark_as_out = true
			var min_speedup = max(resistance, 0.5)
			var old_elastic_vel = elastic_velocity
			elastic_velocity += elastic_vector * elastic_power * (min_speedup)
			if dash_bounce_vector != Vector2.ZERO:
#				elastic_velocity *= 5
				elastic_velocity += dash_bounce_vector * 3
				dash_bounce_vector = Vector2.ZERO
				set_state(STATE.MOVE)
			var n_dot = (velocity+elastic_velocity).dot(old_vel)
#			print(n_dot)
#				end_pull()
		
#		if elastic_velocity.dot(elastic_vector) > 0:
#			end_pull()
		if velocity == Vector2.ZERO and elastic_velocity.dot(elastic_vector) < 0:
#			print('rebounce drag')
			mark_as_out = false
			is_pulling = true
			elastic_velocity = elastic_velocity.normalized() * (max(elastic_velocity.length() - elastic_drag, 0))
	else:
#		print('empty drag')
		elastic_velocity = elastic_velocity.normalized() * (max(elastic_velocity.length() - elastic_drag, 0))
	
	if mark_as_out:
		end_pull()

	velocity += elastic_velocity
	velocity = velocity.limit_length(max_total_speed)
	
	
	if velocity.length() > elastic_kick_speed and elastic_velocity.length() != 0:
		$SpritePersonnage.modulate = Color.BLUE_VIOLET
		check_kick()
	else:
		$SpritePersonnage.modulate = Color.WHITE


func drop_post(drop_position):
	if post_nb > 0 and not GameManager.core.is_off:
		GameManager.level_manager.drop_post(drop_position)
		post_nb -= 1
		if $PostTimer.is_stopped():
			$PostTimer.start()

func get_shader_materials():
	return [$Sprite2D.get_material(), $ombre.get_material()];

func get_reference_velocity():
	return velocity;

func _on_post_timer_timeout():
	post_nb += 1
	if post_nb < post_bag_size:
		$PostTimer.start()

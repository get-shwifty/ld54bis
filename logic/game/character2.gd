extends CharacterBody2D

enum STATE { MOVE, KICK, DASH }
var state: STATE = STATE.MOVE

var next_state: STATE = STATE.MOVE
@export var NEXT_STATE_TIMING_MS = 100

# move
var move_intention: Vector2 = Vector2.ZERO
var orientation: Vector2 = Vector2.ZERO

# kick
@onready var kick_node = $kick
@onready var kick_node_pos = kick_node.position
var kick_direction: Vector2 = Vector2.ZERO
var kick_start_time = 0
@export var KICK_TIME_MS = 100
@export var KICK_FORCE = 300
@export var KICK_COEFF = 0.3

# dash
var dash_direction: Vector2 = Vector2.ZERO
var dash_start_time = -1e6
@export var DASH_TIME_MS = 200
@export var DASH_FORCE = 1000
@export var DASH_MAX_SPEED = 10
@export var DASH_COEFF = 0.2
@export var DASH_COOLDOWN_MS = 1500

# elastic
var elastic_vector = Vector2.ZERO
var elastic_velocity = Vector2.ZERO
var elastic_drag = 200
var elastic_power = 300

const move_base_coef = 50
@export var move_max_speed : float = 4


@export var kick_force : float = 1000

@export var drop_post_offset: float = 1

func _ready():
	GameManager.player = self;

func _physics_process(delta):
	update_move_intention()
	process_orientation(delta)
	
	match state:
		STATE.MOVE:
			velocity = get_move_velocity()

			check_next_state()
			match next_state:
				STATE.KICK:
					kick()
				STATE.DASH:
					dash()
			next_state = STATE.MOVE # reset next_state

			if Input.is_action_just_pressed("game_drop_post"):
				GameManager.try_drop_post(position + orientation * drop_post_offset)
		STATE.KICK:
			kick_state(delta)
		STATE.DASH:
			dash_state(delta)
	
	elastic_movement()
	move_and_slide()

func check_next_state():
	if Input.is_action_just_pressed("game_kick"):
		next_state = STATE.KICK
	elif Input.is_action_just_pressed("game_dash"):
		var last_dash = dash_start_time + DASH_TIME_MS
		if (Time.get_ticks_msec() - last_dash) > DASH_COOLDOWN_MS:
			next_state = STATE.DASH

func process_orientation(delta):
	var mouse_pos : Vector2 = get_global_mouse_position()
	orientation = (mouse_pos - position).normalized()
	var angle = orientation.angle()
	kick_node.position = kick_node_pos.rotated(angle)
	kick_node.rotation = angle

func get_move_velocity():
	return move_intention * move_max_speed * move_base_coef

func update_move_intention():
	move_intention = Vector2.ZERO

	if Input.is_action_pressed("game_right"):
		move_intention.x += 1
	if Input.is_action_pressed("game_left"):
		move_intention.x -= 1
	if Input.is_action_pressed("game_down"):
		move_intention.y += 1
	if Input.is_action_pressed("game_up"):
		move_intention.y -= 1

	move_intention = move_intention.normalized()

func kick_state(delta):
	var delta_time_kick = Time.get_ticks_msec() - kick_start_time
	if delta_time_kick > KICK_TIME_MS:
		state = STATE.MOVE
		return
	elif delta_time_kick > (KICK_TIME_MS - NEXT_STATE_TIMING_MS):
		check_next_state()

	var coeff = float(delta_time_kick) / KICK_TIME_MS
	coeff = -pow(coeff, KICK_COEFF) # TODO params
	velocity = get_move_velocity()
	velocity += kick_direction * coeff * KICK_FORCE

func kick():
	if state == STATE.MOVE:
		state = STATE.KICK
		kick_direction = orientation
		kick_start_time = Time.get_ticks_msec()
		var enemies_to_kick = $kick/KickArea.get_overlapping_bodies()
		for enemy in enemies_to_kick:
			enemy = enemy as BaseEnemy
			enemy.receive_kick(orientation * kick_force)

func dash_state(delta):
	var delta_time_dash = Time.get_ticks_msec() - dash_start_time
	if delta_time_dash > DASH_TIME_MS:
		state = STATE.MOVE
		return
	elif delta_time_dash > (DASH_TIME_MS - NEXT_STATE_TIMING_MS):
		check_next_state()

	var coeff = float(delta_time_dash) / DASH_TIME_MS
	coeff = pow(coeff, DASH_COEFF) # TODO params
	velocity = dash_direction * coeff * DASH_FORCE
	if velocity.length() > (DASH_MAX_SPEED / delta):
		velocity = velocity.normalized() * (DASH_MAX_SPEED / delta)

func dash():
	if state == STATE.MOVE:
		state = STATE.DASH
		dash_direction = orientation
		dash_start_time = Time.get_ticks_msec()

func elastic_movement():
	var m_speed = move_max_speed * move_base_coef
	
	if velocity != Vector2.ZERO:
		elastic_velocity = Vector2.ZERO
	
	if elastic_vector != Vector2.ZERO:
		var resistance = GameManager.elastic.resistance
		var q_res = min(1, resistance) ** 8
		var dot = velocity.dot(elastic_vector)

		if velocity != Vector2.ZERO && dot < 0:
			var velocity_counter = -velocity * resistance
			var elastic_counter = elastic_vector.normalized() * m_speed
			elastic_velocity = (1-q_res)*velocity_counter + q_res*elastic_counter
		else:
			var min_speedup = max(resistance, 0.5)
			elastic_velocity += elastic_vector * elastic_power * (min_speedup)
		
		if velocity == Vector2.ZERO && elastic_velocity.dot(elastic_vector) < 0:
			elastic_velocity = elastic_velocity.normalized() * (max(elastic_velocity.length()-elastic_drag, 0))
	else:
		elastic_velocity = elastic_velocity.normalized() * (max(elastic_velocity.length()-elastic_drag, 0))

	velocity += elastic_velocity

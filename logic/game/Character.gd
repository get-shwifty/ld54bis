extends CharacterBody2D

const move_base_coef = 50
@export var move_max_speed : float = 20


var last_orientation : Vector2;
const kick_force_base_coef = 50;
@export var kick_force : float = 2;

@export var drop_post_offset: float = 1;

var elastic_vector = Vector2.ZERO
var elastic_velocity = Vector2.ZERO
var elastic_drag = 50
var elastic_speed = 0

func _ready():
	GameManager.player = self;

func _physics_process(delta):
	process_orientation(delta);
	process_movement(delta)

	#this should probably be in an update func
	if Input.is_action_just_pressed("game_kick"):
		try_kick()
		
	if Input.is_action_just_pressed("game_drop_post"):
		GameManager.try_drop_post(position + last_orientation * drop_post_offset)
		
	if elastic_vector != Vector2.ZERO:
		$Line2D.set_point_position(1, elastic_vector*100)
		$Line2D.rotation = -rotation


func process_orientation(delta):
	var mouse_pos : Vector2 = get_global_mouse_position();
	var orientation = mouse_pos - position;
	orientation = orientation.normalized()
	last_orientation = orientation;
	look_at(mouse_pos)


func process_movement(delta):
	velocity = get_move_intention() * move_max_speed * move_base_coef
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
			elastic_velocity += elastic_vector * 200 * (min_speedup)
		
		if velocity == Vector2.ZERO && elastic_velocity.dot(elastic_vector) < 0:
			elastic_velocity = elastic_velocity.normalized() * (max(elastic_velocity.length()-elastic_drag, 0))
	else:
		elastic_velocity = elastic_velocity.normalized() * (max(elastic_velocity.length()-elastic_drag, 0))
	
	
	
#	if elastic_vector != Vector2.ZERO:
#		var resistance = GameManager.elastic.resistance
#		elastic_speed += resistance * 100 * -sign(elastic_vector.dot(velocity))
#		if velocity != Vector2.ZERO:
#			elastic_speed = min(move_max_speed * move_base_coef, elastic_speed)
#			elastic_velocity = -velocity.normalized() * elastic_speed
#		else:
#			elastic_velocity += elastic_speed * elastic_vector.normalized() * delta
##		print(velocity)
#	else:
#		elastic_velocity = elastic_velocity.normalized() * elastic_speed
#	velocity += elastic_velocity
##	elastic_speed = max(0, elastic_speed - elastic_drag)
#
	velocity += elastic_velocity
	move_and_slide()

func get_move_intention() -> Vector2:
	var move_intention = Vector2()

	if Input.is_action_pressed("game_right"):
		move_intention.x += 1
	if Input.is_action_pressed("game_left"):
		move_intention.x -= 1
	if Input.is_action_pressed("game_down"):
		move_intention.y += 1
	if Input.is_action_pressed("game_up"):
		move_intention.y -= 1
		
	move_intention = move_intention.normalized()
	return move_intention

func try_kick():
	var enemies_to_kick = $KickArea.get_overlapping_bodies();
	for enemy in enemies_to_kick:
		enemy = enemy as Enemy;
		enemy.receive_kick(last_orientation * kick_force_base_coef * kick_force);

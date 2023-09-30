extends CharacterBody2D

const move_base_coef = 50
@export var move_max_speed : float = 20


var last_orientation : Vector2;
const kick_force_base_coef = 50;
@export var kick_force : float = 2;

func _ready():
	print(get_node("KickArea"))

func _physics_process(delta):
	process_orientation(delta);
	process_movement(delta)

	if Input.is_action_just_pressed("game_kick"):
		try_kick()


func process_orientation(delta):
	var mouse_pos : Vector2 = get_global_mouse_position();
	var orientation = mouse_pos - position;
	orientation = orientation.normalized()
	last_orientation = orientation;
	look_at(mouse_pos)
	

func process_movement(delta):
	velocity = get_move_intention() * move_max_speed * move_base_coef
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

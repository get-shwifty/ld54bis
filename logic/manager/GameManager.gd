extends Node

const DEBUG_UNLIMITED_MONEY = true;


var elastic: Elastic
var player;
var level_manager;

var is_game_over = false
var is_loading = false

var coins : int = 0;
const COST_POST = 5;

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		game_over()
		
	if is_game_over and not is_loading and is_instance_valid(elastic):
		is_loading = true
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://logic/game/game_over.tscn")

func try_drop_post(drop_position :Vector2):
	if coins >= COST_POST or DEBUG_UNLIMITED_MONEY:
		level_manager.drop_post(drop_position);
		coins = coins - COST_POST;

func collect_coin():
	coins = coins + 1;
	score += 1
#	print("coin amount : " + str(coins));

	
func game_over():
	is_game_over = true
	for obj in elastic.object_inside:
		if 'mobile' in obj:
			obj.mobile = true
		else:
			obj.elastic_vector = Vector2.ZERO
	if GameManager.player:
		player.process_mode = PROCESS_MODE_DISABLED

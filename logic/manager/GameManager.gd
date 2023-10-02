extends Node

const DEBUG_UNLIMITED_MONEY = true;


var elastic: Elastic
var player
var level_manager
var core
var score_holder
var camera
var score_bonus_scene = preload("res://ui/bonus_points.tscn")

var is_game_over = false
var is_loading = false
var can_restart = false
var game_over_message = ''

var coins : int = 0;
const COST_POST = 5;

var score = 0
var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if not is_game_over and not is_loading:
		time += delta
	
	if is_game_over and can_restart and Input.is_action_just_pressed("ui_accept"):
		restart()
	
	if is_game_over and not is_loading and is_instance_valid(elastic):
		is_loading = true
		await get_tree().create_timer(0.2).timeout
		get_tree().change_scene_to_file("res://logic/game/game_over.tscn")

func try_drop_post(drop_position :Vector2):
	if coins >= COST_POST or DEBUG_UNLIMITED_MONEY:
		level_manager.drop_post(drop_position);
		coins = coins - COST_POST;

	
func game_over():
	is_game_over = true
	for obj in elastic.object_inside:
		if 'mobile' in obj:
			obj.mobile = true
		else:
			obj.elastic_vector = Vector2.ZERO
	if GameManager.player:
		player.process_mode = PROCESS_MODE_DISABLED

func crush_game_over():
	if is_game_over:
		return
		
	game_over_message = 'Crushed by Darkness'
	game_over()

func no_hp_game_over():
	if is_game_over:
		return
		
	game_over_message = 'Crushed by Ennemies'
	game_over()
	
func restart():
	can_restart = false
	is_game_over = false
	is_loading = false
	score = 0
	time = 0
	get_tree().change_scene_to_file("res://logic/level/world_alexis.tscn")
	
func add_score(source: Node2D, bonus_score):
	var bonus = score_bonus_scene.instantiate()
	score_holder.add_child(bonus)
	bonus.init(source, bonus_score)
	score += bonus_score

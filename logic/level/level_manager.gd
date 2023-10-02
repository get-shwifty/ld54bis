extends Node2D
class_name LevelManager

const SCENE_POST = preload('res://logic/game/post.tscn');
const SCENE_COIN = preload('res://logic/game/coin.tscn');

@onready var enemy_spawner: EnemySpawner = $EnemySpawner

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.level_manager = self;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func drop_post(drop_position : Vector2):
	var post = SCENE_POST.instantiate();
	$Entities/Posts.add_child(post);
	post.position = drop_position;
	GameManager.elastic.add(post)
	return post

func drop_mobile_post(drop_position: Vector2):
	var dropped_post = drop_post(drop_position);
	dropped_post.mobile = true;

func spawn_coin(spawn_position: Vector2, spawn_linear_velocity: Vector2):
	var coin = SCENE_COIN.instantiate();
	$Entities/Coins.add_child(coin);
	coin.position = spawn_position
	coin.linear_velocity = spawn_linear_velocity

func _on_enemy_spawn_timer_timeout():
	var enemy = enemy_spawner.spawn_enemy()
	$Entities/Enemies.add_child(enemy)
	enemy.global_position = enemy.position

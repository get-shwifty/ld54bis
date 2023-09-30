extends Node2D

const SCENE_POST = preload('res://logic/game/post.tscn');

@onready var enemy_spawner = $EnemySpawner as EnemySpawner;

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

func _on_enemy_spawn_timer_timeout():
	var enemy = enemy_spawner.spawn_enemy()
	$Entities/Enemies.add_child(enemy)
	enemy.global_position = enemy.position;

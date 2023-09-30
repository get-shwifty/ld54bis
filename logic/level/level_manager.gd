extends Node2D

@onready var enemy_spawner = $EnemySpawner as EnemySpawner;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_enemy_spawn_timer_timeout():
	var enemy = enemy_spawner.spawn_enemy()
	$Entities/Enemies.add_child(enemy)
	enemy.global_position = enemy.position;

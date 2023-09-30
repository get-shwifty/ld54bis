extends Node2D

@onready var enemy_spawner = $EnemySpawner as EnemySpawner;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_enemy_spawn_timer_timeout():
	null
	#$Entities/Enemies.add_child(enemy_spawner.spawn_enemy())
	#enemy_spawner.global_position = enemy_spawner.position;

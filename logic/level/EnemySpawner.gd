extends Node
class_name EnemySpawner

@onready var DumbEnemy = preload("res://logic/game/enemy/dumb.tscn")

func spawn_enemy():
	var enemy = DumbEnemy.instantiate()
	enemy.position = $SpawnPos.global_position

	return enemy

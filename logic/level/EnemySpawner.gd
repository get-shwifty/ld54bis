extends Node
class_name EnemySpawner

@export var max_difficulty_time = 600

@export var max_concurent_spawns = 4
@export var ennemy1_weight = 9
@export var ennemy2_weight = 6
@export var ennemy3_weight = 3

@onready var ennemy1 = preload("res://logic/game/enemy/dumb.tscn")
@onready var ennemy2 = preload("res://logic/game/enemy/fantom.tscn")
@onready var ennemy3 = preload("res://logic/game/enemy/charger.tscn")




@onready var spawners = $SpawnPositions.get_children()

@onready var DumbEnemy = preload("res://logic/game/enemy/dumb.tscn")

func select_random_enemy():
	var total_weight = ennemy1_weight + ennemy2_weight + ennemy3_weight
	var random = randi_range(1, total_weight)
	
	if random < ennemy1_weight:
		return ennemy1
	if random < ennemy1_weight + ennemy2_weight:
		return ennemy2
	return ennemy3

func spawn_enemy2(spawn_pos, enemy):
	var spawned = enemy.instantiate()
	spawned.position = spawn_pos.global_position
	GameManager.level_manager.spawn(spawned)


func spawn_enemy():
	var enemy = DumbEnemy.instantiate()
	enemy.position = $SpawnPos.global_position

	return enemy
	
func _process(delta):
	pass
	
func get_random_diff(time):
	if time > max_difficulty_time:
		time = max_difficulty_time
	time += randf() - 0.5
	var diff = (cos(time/10) * 160 + time) / 60
	diff = maxf(1, diff)
	diff = minf(10, diff)
	return ceil(diff)


func _on_enemy_spawn_timer_timeout():
	var time = GameManager.time
	var diff = get_random_diff(time)
	
	for i in range(diff):
		var enemy = select_random_enemy()
		var spawn_pos = spawners.pick_random()
		spawn_enemy2(spawn_pos, enemy)

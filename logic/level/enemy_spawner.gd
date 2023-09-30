extends Path2D
class_name EnemySpawner

const SCENE_ENEMY = preload('res://logic/game/enemy.tscn');

func spawn_enemy():
	$spawnPos.offset = randi()
	var enemy = SCENE_ENEMY.instance()
	enemy.position = $spawnPos.position
	
	return enemy
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

extends Path2D

const SCENE_ENEMY = preload('res://logic/game/enemy.tscn');

@onready var spawn_pos : PathFollow2D = $SpawnPostion;

func spawn_enemy():
	spawn_pos.progress_ratio = randf()
	var enemy = SCENE_ENEMY.instantiate();
	enemy.position = spawn_pos.position

	return enemy


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

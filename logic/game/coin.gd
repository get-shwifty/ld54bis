extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Animation.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_collected():
	GameManager.add_score(self, 10000)
	GameManager.player.hp += 3
	if GameManager.player.hp > 100:
		GameManager.player.hp = 100
	$AudioStreamPlayer.play(0.0)
	$Animation.visible = false
	await $AudioStreamPlayer.finished
	queue_free()


func _on_collect_zone_area_entered(area):
	get_collected()

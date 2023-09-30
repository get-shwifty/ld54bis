extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_collected():
	GameManager.collect_coin();
	queue_free();


func _on_collect_zone_area_exited(_area):
	get_collected()

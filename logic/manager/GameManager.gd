extends Node



var elastic: Elastic
var player;
var level_manager;



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func try_drop_post(drop_position :Vector2):
	#check if enough money
	level_manager.drop_post(drop_position);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

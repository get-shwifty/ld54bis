extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Reason.text = GameManager.game_over_message
	$Score.text = 'Score: ' + str(GameManager.score)
	$Restart.visible = GameManager.can_restart


func _on_timer_timeout():
	GameManager.can_restart = true

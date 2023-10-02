extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	$Animation.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Reason.text = '[center]' + GameManager.game_over_message +'[/center]'
	$Score.text = '[center]' + str(GameManager.score) +'[/center]'
	$Restart.visible = GameManager.can_restart


func _on_timer_timeout():
	GameManager.can_restart = true

extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameManager.elastic:
		text = 'size: ' + str(floor(GameManager.elastic.size)) + ' res: ' + str(GameManager.elastic.resistance) + '  speed: ' + str(floor(GameManager.player.velocity.length()))

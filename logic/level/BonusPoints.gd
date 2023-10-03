extends RichTextLabel

var up_speed = -150

func init(target: Node2D, points):
	if points > 1000:
		add_theme_font_size_override("normal_font_size", 45)
	position = target.get_global_transform_with_canvas().get_origin()
	text = ' '+ str(points) + ' '

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += up_speed * delta
	



func _on_end_timer_timeout():
	queue_free()

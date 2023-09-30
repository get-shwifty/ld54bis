extends Sprite2D

@export var test = false

var elastic_vector = Vector2.ZERO
var mobile = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mobile and elastic_vector == Vector2.ZERO:
		queue_free()
		return
	
	if mobile:
		visible = false
		var dir = elastic_vector.normalized() * 40
		global_position = Vector2(global_position.x + dir.x, global_position.y + dir.y)



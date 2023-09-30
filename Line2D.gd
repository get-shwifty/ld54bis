extends Line2D

@export var player: CharacterBody2D = null
@onready var posts = get_node("../Post").get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	clear_points()
	var positions = PackedVector2Array()
	positions.append(player.global_position)
	for p in posts:
		if is_instance_valid(p):
			positions.append(p.global_position)
	
	var convex = Geometry2D.convex_hull(positions)
	
	for p in convex:
		add_point(p)

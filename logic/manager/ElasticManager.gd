extends Node

@onready var line = $Line2D

var object_inside = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for c in get_node("Post").get_children():
		object_inside.append(c)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if len(object_inside) < 3:
		return
	
	var positions = PackedVector2Array()
	var to_del = []
	for obj in object_inside:
		if not is_instance_valid(obj):
			to_del.append(obj)
			continue
		positions.append(obj.global_position)
		
	for del in to_del:
		object_inside.erase(del)
		
	var convex = Geometry2D.convex_hull(positions)
#	print(len(convex))
#	print(convex[-2])
	line.clear_points()
	for p in convex:
		line.add_point(p)
		
	for obj in object_inside:
		var obj_pos = obj.global_position
		var index = convex.find(obj_pos)
		if index < 0:
			obj.elastic_vector = Vector2.ZERO
			continue
		var p1 = Vector2.ZERO
		var p2 = Vector2.ZERO
		if index == 0:
			p1 = convex[-2] # ignore last elem as it is the same as the first
			p2 = convex[1]
		else:
			p1 = convex[index-1]
			p2 = convex[index+1]
			
		var direction = (p1-obj_pos) + (p2 - obj_pos)
		obj.elastic_vector = direction
		
		
		
		
		
		
		

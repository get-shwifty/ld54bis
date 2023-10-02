extends Node
class_name Elastic

@export var player: CharacterBody2D = null
@export var light: Node2D = null
@export var posts: Node2D = null

@export var min_vel_for_sound_trigger = 300;

var max_tension = 2000
var start_tension = 500

var object_inside = []
var size = 0
var resistance = 0

var last_know_convex_hull = [];

func add(obj):
	object_inside.append(obj)

func remove(obj):
	object_inside.remove_at(object_inside.find(obj))

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.elastic = self
	add(player)
#	add(light)

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
	last_know_convex_hull = convex;
	size = 0
	for i in range(len(convex)-1):
		size += (convex[i+1] - convex[i]).length()
		
	if size < start_tension:
		resistance = 0
	elif size >= max_tension:
		resistance = 1
	else:
		resistance = 1 - (max_tension - size) / (max_tension - start_tension)
		resistance = resistance ** 2
	
#	print(len(convex))
#	print(convex[-2])

#	print(len(convex))
#	print(convex)
	
	if len(convex) < 4 or size < 100:
		for obj in object_inside:
			obj.elastic_vector = Vector2.ZERO
		GameManager.crush_game_over()
		return
		
	for obj in object_inside:
		var was_in_elastic = obj.elastic_vector != Vector2.ZERO;
		
		var obj_pos = obj.global_position
		var index = convex.find(obj_pos)
		if index < 0:
			obj.elastic_vector = Vector2.ZERO
		else:
			var p1 = Vector2.ZERO
			var p2 = Vector2.ZERO
			if index == 0:
				p1 = convex[-2] # ignore last elem as it is the same as the first
				p2 = convex[1]
			else:
				p1 = convex[index-1]
				p2 = convex[index+1]
			
#			if not (p1.distance_to(obj_pos) < 10 && 'mobile' in obj and obj.mobile):
			var direction = (p1-obj_pos).normalized() + (p2 - obj_pos).normalized()
			obj.elastic_vector = direction
			
		var is_in_elastic = obj.elastic_vector != Vector2.ZERO;
		if was_in_elastic != is_in_elastic:
			if was_in_elastic:
				print("out")
				$OutSoundPlayer.play(0.0);
			elif obj.get_reference_velocity().length() > min_vel_for_sound_trigger:  
				print("in")
				$InSoundPlayer.play(0.0);
		
		
		

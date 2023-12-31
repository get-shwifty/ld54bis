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
var post_count = 0

var last_know_convex_hull = [];

func add(obj):
	object_inside.append(obj)

func remove(obj):
	object_inside.remove_at(object_inside.find(obj))
	
func is_inside(pos) -> bool:
	var inflated = Geometry2D.offset_polygon(last_know_convex_hull, 20)
	if len(inflated) > 0:
		inflated = inflated[0]
	return Geometry2D.is_point_in_polygon(pos, inflated)

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.elastic = self
	add(player)
#	add(light)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if GameManager.is_game_over:
		return
	
	if len(object_inside) < 2:
		return
	
	var positions = PackedVector2Array()
	var to_del = []
	post_count = 0
	for obj in object_inside:
		if not is_instance_valid(obj):
			to_del.append(obj)
			continue
		if 'mobile' in obj:
			post_count += 1
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
	
	if len(convex) < 3 or size < 100:
		for obj in object_inside:
			obj.elastic_vector = Vector2.ZERO
		GameManager.crush_game_over()
		return
		
	for obj in object_inside:
		var was_in_elastic = obj.elastic_vector != Vector2.ZERO;
		var old_vector = obj.elastic_vector
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
		if is_instance_of(obj, CharacterBody2D) and was_in_elastic != is_in_elastic:
			if was_in_elastic:
				var volume = lerp(-10, 5, old_vector.length() + 0.3)
				print(volume)
				$OutSoundPlayer.volume_db = volume
				$OutSoundPlayer.play(0.0);
			elif obj.get_reference_velocity().length() > min_vel_for_sound_trigger:  
				$InSoundPlayer.play(0.0);
		
		
		

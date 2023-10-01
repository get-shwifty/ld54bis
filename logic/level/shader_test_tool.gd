@tool
extends Node2D

@export var elastic_thickness = 10;

func _process(delta):
	if Engine.is_editor_hint():
		send_info_to_shader();

func send_info_to_shader():
	var count : int = 0;
	var elastic_points = []
	for c in get_node("../Entities/Posts").get_children():
		count += 1;
		elastic_points.append(c.position);

	get_material().set_shader_parameter("elastic_current_points_number", count);
	get_material().set_shader_parameter("elastic_points", elastic_points);
	get_material().set_shader_parameter("elastic_thickness", elastic_thickness);
#
#	for c in $points.get_children():
#		var entity_mat = c.get_material();
#		if entity_mat != null:
#			entity_mat.set_shader_parameter("elastic_current_points_number", count);
#			entity_mat.set_shader_parameter("elastic_points", elastic_points);
#			entity_mat.set_shader_parameter("elastic_thickness", elastic_thickness);

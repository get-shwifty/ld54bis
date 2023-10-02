@tool
extends Node2D

@export var elastic_tension = 0.5;

func _process(delta):
	send_info_to_shader()

func send_info_to_shader():
	var count : int = 0;
	var elastic_points = []
	for c in $points.get_children():
		count += 1;
		elastic_points.append(c.position);

	$ShaderRenderer.get_material().set_shader_parameter("elastic_current_points_number", count);
	$ShaderRenderer.get_material().set_shader_parameter("elastic_points", elastic_points);
	$ShaderRenderer.get_material().set_shader_parameter("current_elastic_tension", elastic_tension);
	
	for c in $points.get_children():
		var entity_mat = c.get_material();
		if entity_mat != null:
			entity_mat.set_shader_parameter("elastic_current_points_number", count);
			entity_mat.set_shader_parameter("elastic_points", elastic_points);
			entity_mat.set_shader_parameter("current_elastic_tension", elastic_tension);

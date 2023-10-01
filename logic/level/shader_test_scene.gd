@tool
extends Node2D


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

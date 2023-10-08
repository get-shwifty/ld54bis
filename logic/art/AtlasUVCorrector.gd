extends Node2D

@onready var parent : AnimatedSprite2D = get_parent(); 

func _process(_delta):
	var texture = parent.sprite_frames.get_frame_texture(parent.animation, parent.frame);
	var region : Rect2 = texture.region;
	var size = texture.atlas.get_size();
	var corrected_position = region.position / size;
	var corrected_size = (region.size - region.position) / size;
	
	var material = get_parent().get_material()
	material.set_shader_parameter("region_position", corrected_position);
	material.set_shader_parameter("region_size", corrected_size);


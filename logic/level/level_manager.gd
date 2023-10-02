extends Node2D
class_name LevelManager

const SCENE_POST = preload('res://logic/game/post.tscn');
const SCENE_COIN = preload('res://logic/game/coin.tscn');

@onready var enemy_spawner = $EnemySpawner
@onready var elastic_node = $Elastic;

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.level_manager = self;
	
	GameManager.elastic.add($Character2)
	for c in $Entities/Posts.get_children():
		GameManager.elastic.add(c)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_shaders();

func drop_post(drop_position : Vector2):
	var post = SCENE_POST.instantiate();
	$Entities/Posts.add_child(post);
	post.position = drop_position;
	GameManager.elastic.add(post)
	return post

func drop_mobile_post(drop_position: Vector2):
	var dropped_post = drop_post(drop_position);
	dropped_post.mobile = true;

func spawn_coin(spawn_position: Vector2, spawn_linear_velocity: Vector2):
	var coin = SCENE_COIN.instantiate();
	$Entities/Coins.add_child(coin);
	coin.position = spawn_position
	coin.linear_velocity = spawn_linear_velocity

func _on_enemy_spawn_timer_timeout():
	var enemy = enemy_spawner.spawn_enemy()
	$Entities/Enemies.add_child(enemy)
	enemy.global_position = enemy.position;

func update_shaders():
	#should be controlled by elastic tension
	var elastic_thickness = 3;
	
	var elastic_points_count : int = elastic_node.last_know_convex_hull.size();
	var elastic_points = elastic_node.last_know_convex_hull;

	$BackgroundShaderRenderer.get_material().set_shader_parameter("elastic_current_points_number", elastic_points_count);
	$BackgroundShaderRenderer.get_material().set_shader_parameter("elastic_points", elastic_points);
	$BackgroundShaderRenderer.get_material().set_shader_parameter("elastic_thickness", elastic_thickness);
	$BackgroundShaderRenderer.get_material().set_shader_parameter("core_position",$Camera2D.get_screen_center_position());
	
	var entities = []
	entities.append_array($Entities/Posts.get_children());
	entities.append_array($Entities/Enemies.get_children());
	entities.append($Character2);
	
	for c in entities:
		var entity_mats = c.get_shader_materials();
		for entity_mat in entity_mats:
			entity_mat.set_shader_parameter("elastic_current_points_number", elastic_points_count);
			entity_mat.set_shader_parameter("elastic_points", elastic_points);
			entity_mat.set_shader_parameter("elastic_thickness", elastic_thickness);

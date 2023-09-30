extends Node

const DEBUG_UNLIMITED_MONEY = true;


var elastic: Elastic
var player;
var level_manager;

var coins : int = 0;
const COST_POST = 5;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func try_drop_post(drop_position :Vector2):
	if coins >= COST_POST or DEBUG_UNLIMITED_MONEY:
		level_manager.drop_post(drop_position);
		coins = coins - COST_POST;

func collect_coin():
	coins = coins + 1;
	print("coin amount : " + str(coins));

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

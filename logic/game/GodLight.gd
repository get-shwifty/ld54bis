extends Node2D

@export var max_hp = 100
@onready var hp = max_hp

var elastic_vector = Vector2.ZERO



func receive_kick(dmg):
#	hp -= dmg
#	if hp <= 0:
	print('you dead')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

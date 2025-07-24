class_name OLDController
extends Node2D

@export var hands: Array[StaticBody2D]

enum yo {dododo, pooo}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for hand in get_children():
		hands.append(hand as StaticBody2D)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func move_hand(index: int, pos: Vector2, delta: float) -> void:
	var direction = pos - hands[index].position
	var new_pos = direction * delta
	hands[index].global_position += new_pos 
	pass

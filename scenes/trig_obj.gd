class_name ObjectTrigger
extends Area3D

@export var key: InteractableObj

@export var use_item: bool
@export var item_key: Equipment

signal activated

func _on_body_entered(body: Node3D) -> void:
	if body is not InteractableObj: return
	if !use_item:
		if body == key:
			body.current_trig = self
	else:
		if body.item == item_key:
			body.current_trig = self

func _on_body_exited(body: Node3D) -> void:
	if body is not InteractableObj: return
	if self == body.current_trig:
		body.current_trig = null

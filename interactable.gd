class_name Interactable
extends Area3D

signal on_interacted(y: bool)

@export var can_interact: bool = true

@export var prompt: String
@export var prompt_sprite: Texture2D

func interact(entity: Entity):
	if !can_interact: return
	prints(entity, "has interacted with", name)
	on_interacted.emit(true)

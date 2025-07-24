class_name Interactable
extends Area3D

@export var prompt: String

func interact(entity: Entity):
	prints(entity, "has interacted with", name)
	

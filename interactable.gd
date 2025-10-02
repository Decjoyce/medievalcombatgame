class_name Interactable
extends PhysicsBody3D

signal on_interact_begin(y: bool)
signal on_interacting(y: bool)
signal on_interact_finished(y: bool)

@export var can_interact: bool = true
enum InteractionTypes {INSTANT, ACTIVE, HOLD}
@export var interact_type: InteractionTypes
@export var allow_npc_interaction: bool = false

@export var prompt: String
@export var prompt_sprite: Texture2D

func interact_begin(entity: Entity, hand: int):
	if !can_interact: return
	prints(entity, "has BEGUN interacting with:", name)
	on_interact_begin.emit(true)

func interacting(entity: Entity, hand: int):
	if !can_interact: return
	#prints(entity, "IS interacting with:", name)
	on_interacting.emit(true)

func interact_finish(entity: Entity, hand: int):
	if !can_interact: return
	prints(entity, "has FINISHED interacting with:", name)
	on_interact_finished.emit(true)

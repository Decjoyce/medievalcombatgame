class_name InteractableObj
extends Interactable

#@export var physics: 

## Object
@export_group("Object")
@export var can_break: bool
@export var num_hands_required_to_lift: int = 1
var is_held: bool

@export_group("Item")
@export var item: Equipment
var current_trig: ObjectTrigger

## Physics Properties
@export var gravity: float = 9.8
@export var mass: float = 1
@export var rb: RigidBody3D

func _ready() -> void:
	# $_col/MeshInstance3D.shape = item.graphics
	pass

func interact_begin(entity: Entity, hand: int):
	super(entity, hand)
	if entity.interaction:
		entity.interaction.begin_grab(self, hand)

func interacting(entity: Entity, hand: int):
	super(entity, hand)
	

func interact_finish(entity: Entity, hand: int):
	super(entity, hand)
	if entity.interaction:
		entity.interaction.end_grab(self, hand)
		if current_trig:
			current_trig.activated.emit()

func throw(_trans: Transform3D):
	#move_and_collide((_trans.basis.z * 1 * mass))
	
	print((_trans.basis.z * 3 * mass))
	var jumpforce = sqrt(3 * -2 * rb.get_gravity().y)
	rb.apply_central_impulse(-basis.z * jumpforce * mass)

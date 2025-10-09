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

@export var bs: bool
@export var bs2: bool
@export var bs3: bool
@onready var bunchofbs : Sprite3D = $Sprite3D

func _ready() -> void:
	# $_col/MeshInstance3D.shape = item.graphics
	pass

func interact_begin(entity: Entity, hand: int):
	super(entity, hand)
	if entity.interaction:
		entity.interaction.begin_grab(self, hand)
		if bs:
			bunchofbs.visible = false

func interacting(entity: Entity, hand: int):
	super(entity, hand)
	

func interact_finish(entity: Entity, hand: int):
	super(entity, hand)
	if entity.interaction:
		if bs3:
			queue_free()
		
		if bs:
			bunchofbs.visible = true
			
		entity.interaction.end_grab(self, hand)
		if current_trig:
			current_trig.activated.emit()

func throw(_trans: Transform3D):
	#move_and_collide((_trans.basis.z * 1 * mass))
	print((_trans.basis.z * 6 * mass))
	rb.linear_velocity = Vector3.ZERO
	var jumpforce = sqrt(6 * -2 * rb.get_gravity().y)
	rb.gravity_scale = 0
	rb.apply_central_impulse(-basis.z * jumpforce * mass)
	call_deferred("huneybun")

func huneybun():
	rb.gravity_scale = 0.112

extends Interactable

var opened: bool

@onready var col: CollisionShape3D = $CollisionShape3D

@onready var start_pos: Vector3 = global_position

func interact_begin(entity: Entity, hand: int):
	if !can_interact: return
	super(entity, hand)
	toggle_door(!opened)

func toggle_door(open: bool) -> void:
	opened = open
	if opened: open_door()
	else: close_door()

func open_door() -> void: 
	col.position = start_pos + (Vector3.UP * 1.5)
	opened = true

func close_door() -> void: 
	col.position = start_pos
	opened = false

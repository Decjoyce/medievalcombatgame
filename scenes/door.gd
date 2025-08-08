extends Interactable

var opened: bool

@onready var col: CollisionShape3D = $CollisionShape3D

func interact(entity: Entity):
	if !can_interact: return
	super(entity)
	toggle_door(!opened)

func toggle_door(open: bool) -> void:
	opened = open
	if opened: open_door()
	else: close_door()

func open_door() -> void: 
	col.position += Vector3.UP * 1.5
	opened = true

func close_door() -> void: 
	col.position -= Vector3.UP * 1.5
	opened = false

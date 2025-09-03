extends Interactable

@onready var pivot: Node3D = $Pivot
var toggled: bool

func interact_begin(entity: Entity, hand: int):
	if !can_interact: return
	prints(entity, "has interacted with", name)
	toggled = !toggled
	if toggled: pivot.rotation_degrees.x = 120
	else: pivot.rotation_degrees.x = 0
	on_interact_begin.emit(toggled)

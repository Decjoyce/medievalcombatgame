class_name Inv_Slot
extends TextureRect

signal slot_entered(slot)
signal slot_exited(slot)

@onready var filter = $StatusFilter

var slot_ID
var is_hovering := false
enum states {DEFAULT, TAKEN, FREE}
var state := states.DEFAULT
var item_stored = null

func set_color(a_state = states.DEFAULT) -> void:
	match a_state:
		states.DEFAULT:
			filter.color = Color(Color.WHITE, 0.0)
		states.TAKEN:
			filter.color = Color(Color.RED, 0.2)
		states.FREE:
			filter.color = Color(Color.GREEN, 0.2)

func _process(delta: float) -> void:
	if get_global_rect().has_point(get_global_mouse_position()):
		if !is_hovering:
			is_hovering = true
			slot_entered.emit(self)
	else:
		if is_hovering:
			is_hovering = false
			slot_exited.emit(self)

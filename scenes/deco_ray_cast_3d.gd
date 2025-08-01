class_name Deco_Raycast3D
extends RayCast3D

## This just gives emits singals for when the ray intersects with something. I feel like it should just be included in the base node but whateves 

var current_collider : Object

signal on_body_entered(obj : Object)
signal on_body_exit(obj : Object)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_colliding():
		if get_collider() == current_collider: return
		on_body_entered.emit(get_collider())
		current_collider = get_collider()
		#print("yo")
	else:
		if current_collider != null:
			on_body_exit.emit(current_collider)
			current_collider = null
		

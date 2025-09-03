extends Control

@export var thekong: TextureRect
@export var thedonkey: Control

var dadonkies: Array[TextureRect]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for da in thedonkey.get_children():
		dadonkies.append(da)
	checkthedarnthing()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	thekong.position = get_global_mouse_position()
	#checkthedarnthing()

func checkthedarnthing() -> void:
	for da in dadonkies:
		if thekong.get_global_rect().intersects(da.get_global_rect()):
			prints(thekong.get_rect(), da.get_rect())
			pass
	await get_tree().create_timer(0.5).timeout
	checkthedarnthing()

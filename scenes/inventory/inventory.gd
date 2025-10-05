extends Control
 

###
#### CURRENT ISSUE: While holding an item [A] in one hand, pick up an item [B] in the other and place it where item [A] was. Try placing item [A] somewhere it can't be placed
#### 				and it will snap back to where it was picked up from but bc theres now an item [B] there, item [A] will break and wont be added to the items array in inv_grid
#### Fix: if player picks up 2 items, keep picked up items' old grid positions as occupied until player puts an item down
###

const item_base = preload("res://scenes/inventory/item_base.tscn")
 
@onready var inv_base = $BG
@onready var grid_bkpk = $GridSlots
@onready var eq_slots = $EquipmentSlots
 
var item_held: Array[TextureRect] = [null, null]
var item_offset: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]
var last_container: Array = [null, null]
var last_pos: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]
 
func _ready():
	pickup_item("sword")
	pickup_item("potato")
	pickup_item("potato")
	pickup_item("sword")
	pickup_item("breastplate")
	pickup_item("breastplate")
	pickup_item("khfdd")
 
 
func _process(delta):
	var cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("left_hand_control"):
		grab(0, cursor_pos)
	if Input.is_action_just_released("left_hand_control"):
		release(0, cursor_pos)
	if item_held[0] != null:
		item_held[0].global_position = cursor_pos + item_offset[0]
		
	if Input.is_action_just_pressed("right_hand_control"):
		grab(1, cursor_pos)
	if Input.is_action_just_released("right_hand_control"):
		release(1, cursor_pos)
	if item_held[1] != null:
		item_held[1].global_position = cursor_pos + item_offset[1]
 
func grab(hand:int, cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		item_held[hand] = c.grab_item(cursor_pos)
		if item_held[hand] != null:
			last_container[hand] = c
			last_pos[hand] = item_held[hand].global_position
			item_offset[hand] = item_held[hand].global_position - cursor_pos
			move_child(item_held[hand], get_child_count())
			#item_held[hand].mouse_filter = Control.MOUSE_FILTER_IGNORE ## SOLUTION
 
func release(hand:int, cursor_pos):
	if item_held[hand] == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		drop_item(hand)
	elif c.has_method("insert_item"):
		if c.insert_item(item_held[hand]):
			item_held[hand] = null
		else:
			return_item(hand)
	else:
		return_item(hand)
 
 
func get_container_under_cursor(cursor_pos):
	var containers = [grid_bkpk, eq_slots, inv_base]
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null
 
func drop_item(hand:int):
	item_held[hand].queue_free()
	item_held[hand] = null
 
func return_item(hand:int):
	item_held[hand].global_position = last_pos[hand]
	last_container[hand].insert_item(item_held[hand])
	item_held[hand] = null
 
func pickup_item(item_id):
	var item = item_base.instantiate()
	item.set_meta("id", item_id)
	item.texture = load(ItemDB.get_item(item_id)["icon"])
	add_child(item)
	item.name = item_id
	if !grid_bkpk.insert_item_at_first_available_spot(item):
		item.queue_free()
		return false
	return true

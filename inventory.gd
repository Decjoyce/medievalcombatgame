class_name Inventory
extends Control

@export var slot_scene: PackedScene
@onready var background: ColorRect = $ColorRect
@onready var grid_container: GridContainer = $ColorRect/MarginContainer/VBoxContainer/GridHolder/GridContainer
@export var item_scene: PackedScene
@onready var col_count = grid_container.columns
@export var hand_left: Control
@export var hand_right: Control

var is_opened: bool = false
var grid_array := []
var item_held: Array[Inv_Item] = [null, null]
var current_slot: Array[Inv_Slot] = [null, null]
var can_place: Array[bool] = [false,false]
var icon_anchor: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]

@export var inv_size: int = 30

func _ready() -> void:
	for i in range(inv_size):
		create_slot()
	if is_opened: open_inventory()
	else: close_inventory()

func _process(delta: float) -> void:
	if item_held[0]:
		if Input.is_action_just_pressed("equipped_action_left"):
			if grid_container.get_global_rect().has_point(hand_left.position):
				place_item(0)
	else:
		if Input.is_action_just_pressed("equipped_action_left"):
			if grid_container.get_global_rect().has_point(hand_left.position):
				pick_item(0)
	
	if item_held[1]:
		if Input.is_action_just_pressed("equipped_action_right"):
			if grid_container.get_global_rect().has_point(hand_right.position):
				place_item(1)
	else:
		if Input.is_action_just_pressed("equipped_action_right"):
			if grid_container.get_global_rect().has_point(hand_right.position):
				pick_item(1)

func create_slot() -> void:
	var new_slot = slot_scene.instantiate() as Inv_Slot
	new_slot.slot_ID = grid_array.size()
	grid_array.push_back(new_slot)
	grid_container.add_child(new_slot)
	new_slot.slot_entered.connect(_on_slot_mouse_enter)
	new_slot.slot_exited.connect(_on_slot_mouse_exit)
	new_slot.hand_left = hand_left
	new_slot.hand_right = hand_right

func toggle_inventory() -> bool:
	is_opened = !is_opened
	if is_opened: open_inventory()
	else: close_inventory()
	return is_opened

func open_inventory() -> void:
	visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1).set_trans(Tween.TRANS_SINE)

func close_inventory() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.1).set_trans(Tween.TRANS_SINE)
	#visible = false

func _on_slot_mouse_enter(a_slot: Inv_Slot, hand: int) -> void:
	icon_anchor[hand] = Vector2(100000, 100000)
	current_slot[hand] = a_slot
	if item_held[hand]:
		check_slot_availablity(current_slot[hand], hand)
		set_grids.call_deferred(current_slot[hand], hand)

func _on_slot_mouse_exit(a_slot, hand: int):
	clear_grid()

func check_slot_availablity(a_slot: Inv_Slot, hand: int) -> void:
	for grid in item_held[hand].item_grids:
		var grid_to_check = a_slot.slot_ID + grid[0] + grid[1] * col_count
		var line_switch_check = a_slot.slot_ID % col_count + grid[0]
		prints(grid, grid_to_check)
		if line_switch_check < 0 or line_switch_check >= col_count:
			can_place[hand] = false
			return
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			can_place[hand] = false
			return
		if grid_array[grid_to_check].state == grid_array[grid_to_check].states.TAKEN:
			can_place[hand] = false
			return
	can_place[hand] = true

func set_grids(a_slot: Inv_Slot, hand: int):
	for grid in item_held[hand].item_grids:
		var grid_to_check = a_slot.slot_ID + grid[0] + grid[1] * col_count
		print(grid_to_check)
		var line_switch_check = a_slot.slot_ID % col_count + grid[0]
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			continue
		if line_switch_check < 0 or line_switch_check >= col_count:
			continue
		
		if can_place[hand]:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].states.FREE)
			
			if grid[1] < icon_anchor[hand].x: icon_anchor[hand].x = grid[1]
			if grid[0] < icon_anchor[hand].y: icon_anchor[hand].y = grid[0]
		else:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].states.TAKEN)

func clear_grid() -> void:
	for grid in grid_array:
		grid.set_color(grid.states.DEFAULT)

func rotate_item(hand: int):
	item_held[hand].rotate_item()
	clear_grid()
	if current_slot[hand]:
		_on_slot_mouse_enter(current_slot[hand], hand)

func place_item(hand:int) -> void:
	if !can_place or !current_slot:
		return
	
	var calculated_grid_id = current_slot[hand].slot_ID + icon_anchor[hand].x * col_count + icon_anchor[hand].y
	item_held[hand]._snap_to(grid_array[calculated_grid_id].global_position)
	
	#item_held.get_parent().remove_child(item_held)
	item_held[hand].reparent(grid_container)
	item_held[hand].global_position = get_global_mouse_position()
	
	item_held[hand].grid_anchor = current_slot
	for grid in item_held[hand].item_grids:
		var grid_to_check = current_slot[hand].slot_ID + grid[0] + grid[1] * col_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].states.TAKEN
		grid_array[grid_to_check].item_stored = item_held[hand]
	
	item_held[hand] = null
	clear_grid()

func pick_item(hand:int):
	if !current_slot[hand] or !current_slot[hand].item_stored:
		return
	item_held[hand] = current_slot[hand].item_stored
	item_held[hand].selected = true
	
	item_held[hand].reparent(self)
	item_held[hand].global_position = get_global_mouse_position()
	
	for grid in item_held[hand].item_grids:
		var grid_to_check = item_held[hand].grid_anchor.slot_ID + grid[0] + grid[1] * col_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].states.FREE
		grid_array[grid_to_check].item_stored = null
	
	check_slot_availablity(current_slot[hand], hand)
	set_grids.call_deferred(current_slot[hand])

func _on_t_button_spawn_pressed() -> void:
	var new_item = item_scene.instantiate()
	add_child(new_item)
	new_item.load_item(randi_range(1, 4))
	new_item.selected = true
	item_held[randi_range(0, 1)] = new_item

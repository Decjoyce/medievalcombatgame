class_name PlayerInteraction
extends Control

@onready var player: Player = get_parent()

var cam: Camera3D

@export var hands: Array[Control] 
var hand_sprites: Array[Control] 
var item_sprites: Array[Control]

@export var hand_speed: Array[float] = [500, 500] 
const INT_RAY_LENGTH = 1.5

var interactables : Array[Interactable] = [null, null]

@export var base_hand_sprite: Texture2D

@export var inv: Inventory

var no: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for han in hands:
		for i in han.get_children():
			if i.name.contains("_hand_sprite_"):
				hand_sprites.append(i)
			if i.name.contains("_item_sprite_"):
				item_sprites.append(i)
	await player.ready
	cam = player.cam
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !player.interacting: return
	
	joystick_movement(delta)
	
	_input_handle()
	
	interact_checker(0)
	interact_checker(1)
	
	grabbing()
	
	if Input.is_action_just_pressed("ui_accept"):
		no = !no
	
	if no:
		warp_mouse(hands[1].position)
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if inv.meactive:
		if hands[1].global_position.y > 430:
			hands[1].scale = Vector2.ONE * 0.6
		else:
			hands[1].scale = Vector2.ONE

func joystick_movement(delta: float) -> void:
	var l_motion := Input.get_vector("l_joystick_left", "l_joystick_right", "l_joystick_down", "l_joystick_up")
	var r_motion := Input.get_vector("r_joystick_left", "r_joystick_right", "r_joystick_down", "r_joystick_up")
	
	move_hand(0, l_motion, delta)
	move_hand(1, r_motion, delta)

func move_hand(hand:int, dir: Vector2, delta: float) -> void:
	if !player.interacting: return
	hands[hand].position += Vector2(dir.x, -dir.y) * hand_speed[hand] * delta
	if hand == 1:
		hands[hand].position.x = clampf(hands[hand].position.x, (size.x / 3.0), size.x - hands[hand].size.x)
	elif hand == 0:
		hands[hand].position.x = clampf(hands[hand].position.x, 0, size.x - (size.x / 3.0) - hands[hand].size.x)
		
	hands[hand].position.y = clampf(hands[hand].position.y, 0 - hands[hand].size.y/2, size.y - hands[hand].size.y)

func _input_handle():
	if Input.is_action_just_pressed("equipped_action_left"):
		begin_interact(0)
	
	if Input.is_action_pressed("equipped_action_left"):
		interacting(0)
	
	if Input.is_action_just_released("equipped_action_left"):
		finish_interact(0)
	
	if Input.is_action_just_pressed("equipped_action_right"):
		begin_interact(1)
	
	if Input.is_action_pressed("equipped_action_right"):
		interacting(1)
	
	if Input.is_action_just_released("equipped_action_right"):
		finish_interact(1)

## Interaction

func interact_checker(hand:int) -> void:
	if !player.interacting: return
	var space_state = cam.get_world_3d().direct_space_state
	
	var origin = cam.project_ray_origin(hands[hand].get_screen_position() + hands[hand].size/2)
	var end = origin + cam.project_ray_normal(hands[hand].position + hands[hand].size/2) * INT_RAY_LENGTH

	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	if !result or !result.collider or result.collider is not Interactable: 
		hand_sprites[hand].texture = base_hand_sprite
		interactables[hand] = null
		return
	
	
	var inter : Interactable = result.collider
	interactables[hand] = inter
	hand_sprites[hand].texture = interactables[hand].prompt_sprite

func begin_interact(hand: int) -> bool:
	if !interactables[hand]: return false
	interactables[hand].interact_begin(player, hand)
	return true

func interacting(hand: int) -> bool:
	if !interactables[hand]: return false
	interactables[hand].interacting(player, hand)
	return true

func finish_interact(hand: int) -> bool:
	if !interactables[hand]: return false
	interactables[hand].interact_finish(player, hand)
	return true


## Grabbing Object
@export var grabbed_objs: Array[InteractableObj] = [null, null]
@export var grab_distance: float = 1.0

func begin_grab(_grabbed_object: InteractableObj, _hand: int) -> void:
	# item_sprites[hand].texture = grabbed_object.item.grabbed_sprite
	grabbed_objs[_hand] = _grabbed_object
	if grabbed_objs[_hand].bs2:
		item_sprites[_hand].visible = true
	pass

func grabbing():
	for i in 2:
		if grabbed_objs[i] == null: continue
		var origin = cam.project_ray_origin(hands[i].get_screen_position() + hands[i].size/2)
		var end = origin + cam.project_ray_normal(hands[i].position + hands[i].size/2) * grab_distance
		grabbed_objs[i].position = end + (Vector3.UP * 0.1) 
		grabbed_objs[i].rotation = player.rotation

func end_grab(_grabbed_object: InteractableObj, _hand: int):
	if grabbed_objs[_hand].bs2:
		item_sprites[_hand].visible = false
	grabbed_objs[_hand] = null
	if hands[_hand].get_screen_position().y <= size.y / 2.8:
		_grabbed_object.throw(player.transform)

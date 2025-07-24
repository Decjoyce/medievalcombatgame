class_name Player
extends Entity

var current_angles: Array[float] = [0, 0]
var current_slots: Array[int] = [0, 0]

const MOUSE_SOFT_ZONE: float = 30000

var con_left_hand: bool
var con_right_hand: bool
@onready var l_hand_pivot: Control = $_graphics/left_hand
@onready var r_hand_pivot: Control = $_graphics/right_hand

@export var starting_equipment: Equipment

@export var stuff: Array[Equipment]
@export var sword_art_l: Control
@export var shield_art_l: Control
@export var sword_art_r: Control
@export var shield_art_r: Control

@onready var cam: Camera3D = $Camera3D
@onready var compass: Node3D = $Node/Compass
@onready var ray_north: RayCast3D = $Node/Compass/North
@onready var ray_east: RayCast3D = $Node/Compass/East
@onready var ray_south: RayCast3D = $Node/Compass/South
@onready var ray_west: RayCast3D = $Node/Compass/West

@export var is_moving: bool
@export var target_pos: Vector3
var speed: float = 4
var turn_speed: float = 8
var target_rotation: float
var is_turning: bool

## Camera Bobbing
const BOB_FREQ = 5
const BOB_AMP = 0.03
var t_bob = 0.0

var can_interact: bool = true
var current_interact: Interactable
@onready var interact_text: Label = $label_interact

func _ready() -> void:
	ray_north.collide_with_areas = true

func joystick_movement() -> void:
	var l_motion := Input.get_vector("l_joystick_left", "l_joystick_right", "l_joystick_down", "l_joystick_up")
	var r_motion := Input.get_vector("r_joystick_left", "r_joystick_right", "r_joystick_down", "r_joystick_up")
	if l_motion:
		if get_stance_angle(1, l_motion):
			if stance.occupy_slot(current_slots[1], 1):
				set_graphics(false)
	
	if r_motion:
		if get_stance_angle(0, r_motion):
			if stance.occupy_slot(current_slots[0], 0): 
				set_graphics(true)

func _headbob(time: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos

func movement(delta: float) -> void:
	target_pos.round()
	if position.distance_to(target_pos) > 0.001:
		#var lerped_position: Vector3
		t_bob += delta * (target_pos - position).length() * speed
		position.x = lerpf(position.x, target_pos.x, speed * delta)
		position.z = lerpf(position.z, target_pos.z, speed * delta)
		#print(lerped_position)
		cam.transform.origin = _headbob(t_bob)
		is_moving = true
		#move_and_collide(lerped_position)
	else:
		is_moving = false
		position = target_pos
	
	
	
	#if is_turning: return
	var move_dir: Vector3
	if Input.is_action_just_pressed("walk_left") and !ray_west.is_colliding():
		target_pos = target_pos - compass.basis.x * Vector3.ONE
		
	if Input.is_action_just_pressed("walk_right")and !ray_east.is_colliding():
		target_pos = target_pos + compass.basis.x * Vector3.ONE
		
	if Input.is_action_just_pressed("walk_up") and !ray_north.is_colliding():
		target_pos = target_pos - compass.basis.z * Vector3.ONE
		
	if Input.is_action_just_pressed("walk_down")and !ray_south.is_colliding():
		target_pos = target_pos + compass.basis.z * Vector3.ONE
		
	target_pos.round()
	#is_moving = true
	

func turn(delta: float) -> void:
	if Input.is_action_just_pressed("turn_left"):
		target_rotation = target_rotation + 1.5708
		compass.global_rotation.y = target_rotation
	if Input.is_action_just_pressed("turn_right"):
		target_rotation = target_rotation - 1.5708
		compass.global_rotation.y = target_rotation
	rotation.y = lerp_angle(rotation.y, target_rotation, delta * turn_speed)
	
	if abs(rotation.y - target_rotation) > 0.01:
		is_turning = true
	else:
		is_turning = false
		rotation.y = target_rotation

func _process(delta: float) -> void:
	compass.position = position
	if Input.is_action_just_pressed("equipped_action"):
		if con_left_hand:
			stance.attack_opponent(1)
		if con_right_hand:
			stance.attack_opponent(0)
	
	if !is_moving and Input.is_action_just_pressed("equipped_action_left"):
		stance.attack_opponent(1)
	
	if !is_moving and Input.is_action_just_pressed("equipped_action_right"):
		stance.attack_opponent(0)
	
	if Input.is_action_just_pressed("interact") and can_interact and current_interact:
		current_interact.interact(self)
		interact_text.text = ""
	
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	joystick_movement()
	movement(delta)
	turn(delta) 

func get_stance_angle(hand: int, dir: Vector2) -> bool:
	current_angles[hand] = rad_to_deg(atan2(dir.y, -dir.x))
	var _slot = floorf((current_angles[hand] + 22.5)/45) + 4
	if _slot >= 8:
		_slot = 0
	if _slot == current_slots[hand]: return false
	else:
		current_slots[hand] = int(_slot)
		return true
	#print(current_angle)

func get_stance_angle0(dir: Vector2) -> bool:
	current_angles[0] = rad_to_deg(atan2(dir.y, -dir.x))
	var _slot = floorf((current_angles[0] + 22.5)/45) + 4
	if _slot >= 8:
		_slot = 0
	if _slot == current_slots[0]: return false
	else:
		current_slots[0] = int(_slot)
		return true

func get_stance_angle1(dir: Vector2) -> bool:
	current_angles[1] = rad_to_deg(atan2(dir.y, -dir.x))
	var _slot = floorf((current_angles[1] + 22.5)/45) + 4
	if _slot >= 8:
		_slot = 0
	if _slot == current_slots[1]: return false
	else:
		current_slots[1] = int(_slot)
		return true

func set_graphics(r_hand: bool, use_mouse: bool = false) -> void:
	if !r_hand:
		l_hand_pivot.rotation_degrees = 45 * (current_slots[1] + 4)
		if use_mouse:
			stance.set_slot_active_display(1)
	else:
		r_hand_pivot.rotation_degrees = 45 * current_slots[0]
		if use_mouse:
			stance.set_slot_active_display(0)

var yo_l: int = 2
var yo_r: int = 0
func _on_button_pressed() -> void:
	yo_l = wrapi(yo_l +1, 0, 3)
	stance.hands[1] = stuff[yo_l]
	#print()
	if yo_l == 2:
		sword_art_l.visible = false
		shield_art_l.visible = true
	else:
		sword_art_l.visible = true
		shield_art_l.visible = false
	stance.set_slot_display()

func _on_button_2_pressed() -> void:
	yo_r = wrapi(yo_r +1, 0, 3)
	stance.hands[1] = stuff[yo_r]
	if yo_r == 2:
		sword_art_r.visible = false
		shield_art_r.visible = true
	else:
		sword_art_r.visible = true
		shield_art_r.visible = false
	stance.set_slot_display()

func on_raycast_enter(obj: Object) -> void:
	if obj is Interactable:
		var interactable: Interactable = obj as Interactable
		interact_text.text = interactable.prompt
		current_interact = interactable

func on_raycast_exit(obj: Object) -> void:
	if obj is Interactable:
		#var interactable: Interactable = obj as Interactable
		interact_text.text = ""
		current_interact = null

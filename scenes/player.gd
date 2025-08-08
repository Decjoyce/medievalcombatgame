class_name Player
extends Entity

var current_angles: Array[float] = [0, 0]
var current_slots: Array[int] = [0, 0]

const MOUSE_SOFT_ZONE: float = 30000

var con_left_hand: bool
var con_right_hand: bool
@onready var l_hand_pivot: Control = $_graphics/left_hand
@onready var r_hand_pivot: Control = $_graphics/right_hand

@onready var cam: Camera3D = $Camera3D

## Compass - is parented to just a Node (not Node3D). This allows it to be rotated independently of the player.
## By having it as node3d, it gives access to functions and info like its relative x and z directions (basis.x, basis.z)
## Its rotation is the target rotation of the player.
@onready var compass: Node3D = $Node/Compass

@onready var ray_north: RayCast3D = $Node/Compass/North ## Checks if player can move forward and also temporary interact
@onready var ray_east: RayCast3D = $Node/Compass/East ## Checks if player can move right
@onready var ray_south: RayCast3D = $Node/Compass/South ## Checks if player can move back
@onready var ray_west: RayCast3D = $Node/Compass/West ## Checks if player can move left

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

## Controls the which slots to occupy
func joystick_movement(delta: float) -> void:
	var l_motion := Input.get_vector("l_joystick_left", "l_joystick_right", "l_joystick_down", "l_joystick_up")
	var r_motion := Input.get_vector("r_joystick_left", "r_joystick_right", "r_joystick_down", "r_joystick_up")
	
	if !interacting:
		if l_motion:
			if get_stance_angle(1, l_motion):
				if stance.occupy_slot(current_slots[1], 1):
					set_graphics(false)
		
		if r_motion:
			if get_stance_angle(0, r_motion):
				if stance.occupy_slot(current_slots[0], 0): 
					set_graphics(true)
	else:
		if l_motion:
			int_move_hand(1, l_motion, delta)
		
		if r_motion:
			int_move_hand(0, r_motion, delta)

## This is a really headbob formula. It doesn't return to center. It does look weird without it tho 
func _headbob(time: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos

## Movement
## I did this some backass way tbh
func movement(delta: float) -> void:
	target_pos.round() 
	if position.distance_to(target_pos) > 0.001: ## This is conditioned so we can know if player is moving, to stop them from being able to attack while moving
		t_bob += delta * (target_pos - position).length() * speed ## some headbobbing formula i used before. Its really bad.
		
		## Its really jarring just snapping to position
		position.x = lerpf(position.x, target_pos.x, speed * delta)
		position.z = lerpf(position.z, target_pos.z, speed * delta)
		#print(lerped_position)
		cam.transform.origin = _headbob(t_bob)
		is_moving = true
		#move_and_collide(lerped_position)
	else:
		is_moving = false
		position = target_pos ## lerping never reaches the target, so we snap player to it slightly once in range
	
	
	## The Compass is used to get the desired direction the player should move in. The players rotation is lerped so its not always at a quater angle (0, 90, 180, 360).
	## The Compass is independent of the players rotation and it's rotation is equal to target rotation which allows player to move and rotate while still keeping to the grid.
	var move_dir: Vector3
	## The ray is used to check if something is in the way. 
	## The reason why u can phase through walls if you spam in a dir is bc the ray is only 1 unit long and if you're inbetween and move, it wont detect the wall bc the ray ain't long enough
	## Should be super easy to fix
	if Input.is_action_just_pressed("walk_left") and !ray_west.is_colliding():
		target_pos = target_pos - compass.basis.x * Vector3.ONE
		
	if Input.is_action_just_pressed("walk_right")and !ray_east.is_colliding():
		target_pos = target_pos + compass.basis.x * Vector3.ONE
		
	if Input.is_action_just_pressed("walk_up") and !ray_north.is_colliding():
		
		target_pos = target_pos - compass.basis.z * Vector3.ONE
		
	if Input.is_action_just_pressed("walk_down")and !ray_south.is_colliding():
		target_pos = target_pos + compass.basis.z * Vector3.ONE
		
	target_pos.round() ## I cant remember why I round
	#is_moving = true
	

## Player Rotation. 
func turn(delta: float) -> void:
	if Input.is_action_just_pressed("turn_left"):
		target_rotation = target_rotation + 1.5708 ## I used radians for some odd reason
		## The compass' rotation is independent of player and is used as a way to get the direction of the target rotation. 
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
	if Input.is_action_just_pressed("equipped_action"): ## This was for mouse controls and is now obselete
		if con_left_hand:
			stance.attack_opponent(1)
		if con_right_hand:
			stance.attack_opponent(0)
	
	if !is_moving and Input.is_action_just_pressed("equipped_action_left"): ## Left Trigger
		if !interacting: stance.attack_opponent(1)
		else: int_interact(1)
	
	if !is_moving and Input.is_action_just_pressed("equipped_action_right"): ## Right Trigger
		if !interacting: stance.attack_opponent(0)
		else: int_interact(0)
	
	if Input.is_action_just_pressed("interact"):
		if !interacting: int_enter_interactmode()
		else: int_exit_interactmode()
	
	if Input.is_action_just_pressed("reset"): 
		get_tree().reload_current_scene()
	
	joystick_movement(delta)

func _physics_process(delta: float) -> void:
	#joystick_movement(delta)
	int_interact_checker(0)
	int_interact_checker(1)
	movement(delta)
	turn(delta) 

## Calculates the stance slot from the joystick position. Link to explaination : https://cdn.discordapp.com/attachments/1359852606922424510/1400788747712466995/stanceslot_calculation.png?ex=688de9ae&is=688c982e&hm=5fb4efc8bb20ca3642d9afa7c608a74fe520c4cdda1591bf06aae84a41c07d39&
func get_stance_angle(hand: int, dir: Vector2) -> bool:
	current_angles[hand] = rad_to_deg(atan2(dir.y, -dir.x)) ## Does the unit circle thingy
	var _slot = floorf((current_angles[hand] + 22.5)/45) + 4 ## This turns that angle into a 0-7 integer that corresponds to the stance slots. Better explaination in image above
	#print(_slot)
	if _slot >= 8:
		_slot = 0
	if _slot == current_slots[hand]: return false ## This stops it from going through all the calculations of occupying a slot and graphics if the player is holding the joystick in the same direction
	else:
		current_slots[hand] = int(_slot) ## Cant remember why i had to cast it and not just floorf_i() earlier, idk if this is required or not
		return true ## This allows it to go through all the occupying slot calculations

## This just rotates the item graphics to match where 
## use_mouse is obselete, i should get rid of it but cba
func set_graphics(r_hand: bool, use_mouse: bool = false) -> void:
	if !r_hand:
		l_hand_pivot.rotation_degrees = 45 * (current_slots[1] + 4) ## Reverts the slot back to an angle
		if use_mouse:
			stance.set_slot_active_display(1)
	else:
		r_hand_pivot.rotation_degrees = 45 * current_slots[0]
		if use_mouse:
			stance.set_slot_active_display(0)

## Used for interacting
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


###### INTERACTION

@export var int_hands: Array[TextureRect] 
var interacting: bool =  true
@export var int_hand_speed: float = 500 
const INT_RAY_LENGTH = 1000
@onready var int_ui_stance : Node3D = $Camera3D/_ui_stance
var int_interactable : Array[Interactable] = [null, null]

@export var temp_int_base_hand: Texture2D

func int_enter_interactmode() -> void:
	interacting = true
	for han in int_hands:
		han.visible = true
	int_ui_stance.visible = false
	l_hand_pivot.visible = false
	r_hand_pivot.visible = false
	cam.fov = 95

func int_exit_interactmode() -> void:
	interacting = false
	for han in int_hands:
		han.visible = false
	int_ui_stance.visible = true
	l_hand_pivot.visible = true
	r_hand_pivot.visible = true
	cam.fov = 90

func int_move_hand(hand:int, dir: Vector2, delta: float) -> void:
	if !interacting: return
	int_hands[hand].position += Vector2(dir.x, -dir.y) * int_hand_speed * delta
	var screen_size : Vector2i = get_viewport().size
	int_hands[hand].position.x = clampf(int_hands[hand].position.x, 0, screen_size.x - int_hands[hand].size.x)
	int_hands[hand].position.y = clampf(int_hands[hand].position.y, 0, screen_size.y - int_hands[hand].size.y)

func int_interact_checker(hand:int) -> void:
	if !interacting: return
	var space_state = get_world_3d().direct_space_state

	var origin = cam.project_ray_origin(int_hands[hand].position + int_hands[hand].size/2)
	var end = origin + cam.project_ray_normal(int_hands[hand].position + int_hands[hand].size/2) * INT_RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	if !result.collider or result.collider is not Interactable: 
		int_hands[hand].texture = temp_int_base_hand
		int_interactable[hand] = null
		return
	
	var inter : Interactable = result.collider
	int_interactable[hand] = inter
	int_hands[hand].texture = int_interactable[hand].prompt_sprite

func int_interact(hand: int) -> bool:
	if !int_interactable[hand]: return false
	int_interactable[hand].interact(self)
	return true

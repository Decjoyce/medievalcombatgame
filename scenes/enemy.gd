class_name Enemy
extends Entity

@export var timer: Timer
@export var timer2: Timer

@export var disabled: bool = true

@onready var stance_graphic: Node3D = $_ui_stance

var enemy: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## This needs to be redone, if player goes behind them than the wont detect the player.
	stance.enemy_entered_range.connect(enemy_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#if enemy:
	#	look_at(enemy.position) ## This shouldn't be used bc its not grid-standardized

## Just rotates to face player and stores them as their enemy
func enemy_entered(_new_enemy: Entity) -> void:
	stance_graphic.visible = true
	enemy = _new_enemy as Player
	if !attack_queue:
		first_attack()
	if enemy:
		#look_at(enemy.position)
		pass
	else:
		stance_graphic.visible = false


var rng: RandomNumberGenerator
## This timer is change hand positions (which slots to occupy)
func _on_timer_timeout() -> void:
	if disabled: return
	var rng := RandomNumberGenerator.new()
	stance.occupy_slot(rng.randi_range(0, 7), rng.randi_range(0, 1))
	timer.wait_time = rng.randf_range(0.5, 2.0)
	timer.start()

## This timer is to attack
func _on_timer_2_timeout() -> void:
	if disabled: return
	var rng := RandomNumberGenerator.new()
	stance.attack_opponent(rng.randi_range(0, 1))
	timer2.wait_time = rng.randf_range(0.5, 3.0)
	timer2.start()

@onready var timer_rec: Timer = $Timer_Recovery
@onready var timer_windup: Timer = $Timer_Windup
@onready var timer_attack: Timer = $Timer_Attack

@onready var is_attacking: bool = false

func first_attack() -> void:
	var rng := RandomNumberGenerator.new()
	var d := rng.randi_range(0, potential_attacks.size() -1)
	attack_queue = potential_attacks[current_attack_index].attacks_queue
	
	print(potential_attacks[d].a_name)
	print(attack_queue[current_attack_index].s_name)
	timer_rec.wait_time = attack_queue[current_attack_index].recovery_time
	timer_windup.wait_time = attack_queue[current_attack_index].wind_up_time
	timer_attack.wait_time = attack_queue[current_attack_index].attack_time
	
	is_attacking = false
	timer_rec.start()

func new_attack() -> void:
	current_attack_index += 1
	if current_attack_index >= attack_queue.size():
		var rng := RandomNumberGenerator.new()
		var d := rng.randi_range(0, potential_attacks.size() - 1)
		attack_queue = potential_attacks[d].attacks_queue
	
		print(potential_attacks[d].a_name)
		current_attack_index = 0
	
	print(attack_queue[current_attack_index].s_name)
	timer_rec.wait_time = attack_queue[current_attack_index].recovery_time
	timer_windup.wait_time = attack_queue[current_attack_index].wind_up_time
	timer_attack.wait_time = attack_queue[current_attack_index].attack_time
	
	#for o in attack_tweens:
	#	o.kill()
	
	is_attacking = false
	timer_rec.start()

func recover() -> void:
	pass

func windup() -> void:
	is_attacking = true
	#attack_graphics.clear()
	#attack_graphics.resize(attack_queue[current_attack_index].hand_attack_strings.size())
	
	for i in attack_queue[current_attack_index].hand_attack_strings.size():
		stance.occupy_slot(attack_queue[current_attack_index].hand_attack_strings[i], i)
		#attack_graphics[i].append(uiattack[i])
		var attack_tween = uiattack[i].create_tween()
		attack_tweens.append(attack_tween)
		attack_tweens[i].set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		attack_tweens[i].set_parallel()
		attack_tweens[i].tween_property(uiattack[attack_queue[current_attack_index].hand_attack_strings[i]], "scale", Vector3.ONE, timer_windup.wait_time).set_trans(Tween.TRANS_SINE)
		
		#prints(i, uiattack[attack_queue[current_attack_index].hand_attack_strings[i]], attack_tweens[i].is_valid())
	
	#create_tween()
	timer_windup.start()
	

var attack_graphics: Array

var attack_tweens: Array[Tween]

@export var potential_attacks: Array[AttackList]
@export var attack_queue: Array[AttackData]
@export var current_attack_index: int

func attack_q() -> void:
	for i in attack_queue[current_attack_index].hand_attacking.size():
		stance.attack_opponent(i)
	timer_attack.start()
	for o in attack_tweens:
		o.kill()
	attack_tweens.clear()
	for i in uiattack:
		i.scale = Vector3.ZERO
	#sprite changing thing

@export var uiattack : Array[Sprite3D]

#Or Windup begin
func _on_recovery_end() -> void:
	#print("John")
	windup()

#Attack Begin
func _on_wind_up_end() -> void:
	#print("Cena")
	attack_q()

#Recovery Begin
func _on_attack_end() -> void:
	#print("69")
	recover()
	new_attack()


func _on_timer_recovery_timeout() -> void:
	pass # Replace with function body.

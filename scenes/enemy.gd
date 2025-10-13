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
	if enemy:
		look_at(enemy.position) ## This shouldn't be used bc its not grid-standardized

## Just rotates to face player and stores them as their enemy
func enemy_entered(_new_enemy: Entity) -> void:
	stance_graphic.visible = true
	enemy = _new_enemy as Player
	first_attack()
	if enemy:
		look_at(enemy.position)
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
	timer_rec.wait_time = attack_queue[current_attack_index].recovery_time
	timer_windup.wait_time = attack_queue[current_attack_index].wind_up_time
	timer_attack.wait_time = attack_queue[current_attack_index].attack_time
	
	is_attacking = false
	timer_rec.start()

func new_attack() -> void:
	current_attack_index = + 1
	if current_attack_index >= attack_queue.size():
		current_attack_index = 0
	
	timer_rec.wait_time = attack_queue[current_attack_index].recovery_time
	timer_windup.wait_time = attack_queue[current_attack_index].wind_up_time
	timer_attack.wait_time = attack_queue[current_attack_index].attack_time
	
	is_attacking = false
	timer_rec.start()

func recover() -> void:
	pass

func windup() -> void:
	is_attacking = true
	for i in attack_queue[current_attack_index].hand_attack_strings.size():
		stance.occupy_slot(attack_queue[current_attack_index].hand_attack_strings[i], i)
	

@export var attack_queue: Array[AttackData]
@export var current_attack_index: int

func attack_q() -> void:
	for i in attack_queue[current_attack_index].hand_attacking.size():
		stance.attack_opponent(i)
	#sprite changing thing

@export var uiattack : Array[Sprite3D]

#Or Windup begin
func _on_recovery_end() -> void:
	print("John")
	windup()
	for i in attack_queue[current_attack_index].hand_attack_strings.size():
		var dog = uiattack[attack_queue[current_attack_index].hand_attack_strings[i]]
		print(dog)
		var tween = get_tree().create_tween()
		print(tween)
		tween.tween_property(dog, "scale", Vector3(), 1.0).set_trans(Tween.TRANS_BOUNCE)
	timer_windup.start()

#Attack Begin
func _on_wind_up_end() -> void:
	print("Cena")
	attack_q()
	timer_attack.start()

#Recovery Begin
func _on_attack_end() -> void:
	print("69")
	recover()
	new_attack()


func _on_timer_recovery_timeout() -> void:
	pass # Replace with function body.

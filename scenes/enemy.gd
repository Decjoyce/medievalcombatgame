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

class_name Stats
extends Node


## Derrived Stats
@export var max_health: int
@export var current_health: int

@export var health_bar: ProgressBar

@export var temp_damage_indicator: Node

@export var audio_death: AudioStreamPlayer

func take_damage(amount: int) -> bool:
	current_health -= amount
	temp_flash()
	health_bar.value = current_health
	if current_health <= 0:
		die()
		return true
	return false

func heal(amount: int) -> void:
	current_health += amount
	#temp_flash()
	health_bar.value = current_health
	if current_health > max_health:
		current_health = max_health

func die() -> void:
	audio_death.play()
	get_parent().queue_free()

func temp_flash() -> void:
	temp_damage_indicator.visible = true
	await get_tree().create_timer(0.1).timeout
	temp_damage_indicator.visible = false

@export var max_stamina: float
@export var current_stamina: float

@export var stam_bar: ProgressBar

func _on_timer_stam_timeout() -> void:
	current_stamina = max_stamina

@export var base_damage: int
@export var base_defence: int

func _ready() -> void:
	current_health = max_health
	current_stamina = max_stamina
	if stam_bar:
		stam_bar.max_value = max_stamina
	if health_bar:
		health_bar.max_value = max_health

func _process(delta: float) -> void:
	if stam_bar:
		stam_bar.value = current_stamina

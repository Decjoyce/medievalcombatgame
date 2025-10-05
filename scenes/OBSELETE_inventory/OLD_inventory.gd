extends Node

@export var slot_scene: PackedScene
@onready var grid_container: GridContainer = $ColorRect/MarginContainer/VBoxContainer/GridContainer

var grid_array := []

@export var inv_size: int = 30

func _ready() -> void:
	for i in range(inv_size):
		create_slot()

func create_slot() -> void:
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_array.size()
	grid_container.add_child(new_slot)
	new_slot.slot_entered.connect(_on_slot_mouse_enter)
	new_slot.slot_exited.connect(_on_slot_mouse_exit)

func _on_slot_mouse_enter(a_slot):
	a_slot.set_color(a_slot.states.TAKEN)

func _on_slot_mouse_exit(a_slot):
	a_slot.set_color(a_slot.states.DEFAULT)

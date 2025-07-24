class_name Equipment
extends Resource

@export var equipment_name: String

## Stats
@export var offense_rating: int
@export var defense_rating: int

@export_range(0, 4, 1) var num_slots_down: int = 0
@export_range(0, 4, 1) var num_slots_up: int = 0
@export var restrict_slots_by_hand: Array[String]

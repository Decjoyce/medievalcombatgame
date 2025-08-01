class_name Equipment
extends Resource

@export var equipment_name: String

## Stats
@export var offense_rating: int
@export var defense_rating: int

## The number of additional slots the equipment will occupy, like how the shield takes up 3 slots. 
@export_range(0, 4, 1) var num_slots_down: int = 0
@export_range(0, 4, 1) var num_slots_up: int = 0

## Resticts what slots the item can occupy while it is the corresponding hand. 
## Must be an 8 char String of 0s and 1s. Each char represents a slot (i.e. String[0] is right) and the value of the char tells if it can occupy that slot, 0 - no, 1 - yes
@export var restrict_slots_by_hand: Array[String]

class_name Stance 
extends Node

## I tried making this universal, both the player and enemies use the same node.
## You can't have an enemy with more than 2 hands currently as I got tunnel visioned with getting the player to work.
## This whole system should be and needs to be reworked. Theres definitely way easier ways of doing it. Theres so many for loops

### STANCE - refers to the whole system

### SLOTS - are the 8 points of the octagon. The variable holds info on what hand is occupying which slot.
### HANDS - are what occupy the slots.

enum stance_slots {RIGHT, BOTTOM_RIGHT, BOTTOM, BOTTOM_LEFT, LEFT, TOP_LEFT, TOP, TOP_RIGHT}
@export var slots: Array[int] = [-1, -1, -1, -1, -1, -1, -1, -1] # 8 Elements each corresponding to a stance_slot, values corresponds to a hand, -1 = empty, 1 means hand[1] is occupyin
@export var hands: Array[Equipment]

@export var stats: Stats

@export var opponent: Stance

@export var temp_timer_stam: Timer

@export var temp_octagon_display: Array[Sprite3D]

@export var audio_player_miss: AudioStreamPlayer
@export var audio_player_hit: AudioStreamPlayer

signal enemy_entered_range(enemy: Entity)

func _ready() -> void:
	occupy_slot(0, 0)
	occupy_slot(4, 1) 
	set_slot_display() 

## 
func occupy_slot(new_slot: stance_slots, hand: int) -> bool:
	if !can_occupy_slot(new_slot, hand): return false
	clear_slots(hand)
	slots[new_slot] = hand
	
	## This calculates how many slots, up or down, that hand's current weapon takes up.
	for i in hands[hand].num_slots_down:
		var wrapped_slot: int = wrapi(new_slot-(i+1), 0, 8)
		#print(wrapped_slot)
		slots[wrapped_slot] = hand
	for i in hands[hand].num_slots_up:
		var wrapped_slot: int = wrapi(new_slot+(i+1), 0, 8)
		#print(wrapped_slot)
		slots[wrapped_slot] = hand
	
	set_slot_display()
	#prints( "yo", wrapi(-2, 0, 8))
	return true

## Clears any slot that the hand currently occupies
func clear_slots(hand: int) -> void:
	for i in slots.size():
		if slots[i] == hand:
			#print("yo")
			slots[i] = -1

## Checks if slot can be occupied or not
func can_occupy_slot(new_slot: stance_slots, hand: int) -> bool:
	## Equipment can determine what slots it can occupy for whichever hand slot it is in. This is stored as an 8 char String of 0s or 1s.
	## Each char corresponds to a slot. 0 means this slot cannot be occupied, 1 means it can be occupied
	var restricted_slots : String = hands[hand].restrict_slots_by_hand[hand]
	if restricted_slots[new_slot] == "0": return false
	
	## The next bit checks if there's a hand is already occupying slots that you want to move into.
	for i in hands[hand].num_slots_down:
		var wrapped_slot: int = wrapi(new_slot-(i+1), 0, 8)
		if  slots[wrapped_slot] != -1 and slots[wrapped_slot] != hand: return false
	for i in hands[hand].num_slots_up:
		var wrapped_slot: int = wrapi(new_slot+(i+1), 0, 8)
		if slots[wrapped_slot] != -1 and slots[wrapped_slot] != hand: return false
	
	if slots[new_slot] != -1 and slots[new_slot] != hand: 
		#print("yo")
		return false
	else:
		return true

## If you are attacking. Deffo needs redoing.
## Essentially, you which hand your attacking with and the slots that that hand occupies in binary string format (same used as restricted slots)
func attack_opponent(hand:int) -> void:
	if !opponent: return
	if stats.current_stamina <= 0: return
	var attacked_slots: String
	
	for i in slots:
		if i == hand:
			attacked_slots += "1"
		else:
			attacked_slots += "0"
	stats.current_stamina -= 10
	temp_timer_stam.start()
	opponent.on_attacked(attacked_slots, hands[hand])

## If you are being attacked
func on_attacked(attack_dirs: String, equipment: Equipment) -> void:
	var cur_dir: int = 0
	for i in 8: ## Iterates through each slot
		cur_dir = int(attack_dirs[i]) ## Returns char back to int
		if cur_dir == 1:
			if slots[i] != -1: ## Checks if you have something equipped so you can block.
				print("Attempting to Block")
				
				var damage_done : int = equipment.offense_rating - hands[slots[i]].defense_rating ## Does damage threshold calculation
				
				if damage_done > 0: # If the attack broke through the threshold, take some damage
					stats.take_damage(damage_done)
					prints("Not So Ouch!", damage_done)
				else: # If it doesnt, dont. 
					print("HAHA, SUCKER")
					
				audio_player_miss.play()
			else: # You have nothing to block with, take the full damage
				stats.take_damage(equipment.offense_rating)
				print("Ouch!!!!!!")
				audio_player_hit.play()

## Make the slot thats being occupied white on the octagon ui
## This needs redoing. It uses sprite3ds for the octagon ui for the enemy but then it forces the player to have to use sprite3ds.
func set_slot_display() -> void:
	for i in slots.size():
		if slots[i] == -1: temp_octagon_display[i].visible = false
		else: temp_octagon_display[i].visible = true

## Obsolete, was used with mouse controls to show which hand is currently active
func set_slot_active_display(hand: int) -> void:
	for i in slots.size():
		if slots[i] == hand: temp_octagon_display[i].modulate = Color(1.0, 0.767, 0.0)
		else: temp_octagon_display[i].modulate = Color(1.0, 1.0, 1.0)

## Used to check if you're facing an enemy and if are, to make them your current opponent. 
func _on_raycast_enter(obj: Object) -> void:
	if obj as Entity and opponent != obj.stance:
			print(obj)
			var enemy = obj as Entity
			enemy_entered_range.emit(enemy)
			opponent = enemy.stance

func _on_raycast_exit(obj: Object) -> void:
	if obj as Entity and opponent == obj.stance:
			opponent = null
			enemy_entered_range.emit(null)

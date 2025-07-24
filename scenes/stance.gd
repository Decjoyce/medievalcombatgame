class_name Stance 
extends Node

enum stance_slots {RIGHT, BOTTOM_RIGHT, BOTTOM, BOTTOM_LEFT, LEFT, TOP_LEFT, TOP, TOP_RIGHT}
@export var slots: Array[int] = [-1, -1, -1, -1, -1, -1, -1, -1] # 8 Elements each corresponding to a stance_slot, values corresponds to a hand, -1 = empty
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

func occupy_slot(new_slot: stance_slots, hand: int) -> bool:
	if !can_occupy_slot(new_slot, hand): return false
	clear_slots(hand)
	slots[new_slot] = hand
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

func clear_slots(hand: int) -> void:
	for i in slots.size():
		if slots[i] == hand:
			#print("yo")
			slots[i] = -1

func can_occupy_slot(new_slot: stance_slots, hand: int) -> bool:
	var restricted_slots = hands[hand].restrict_slots_by_hand[hand]
	if restricted_slots[new_slot] == "0": return false
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

func on_attacked(attack_dirs: String, equipment: Equipment) -> void:
	var cur_dir: int = 0
	for i in 8:
		cur_dir = int(attack_dirs[i]) 
		if cur_dir == 1:
			if slots[i] != -1:
				print("Attempting to Block")
				var damage_done : int = equipment.offense_rating - hands[slots[i]].defense_rating
				if damage_done > 0:
					stats.take_damage(damage_done)
					prints("Not So Ouch!", damage_done)
				else:
					print("HAHA, SUCKER")
				audio_player_miss.play()
			else:
				stats.take_damage(equipment.offense_rating)
				print("Ouch!!!!!!")
				audio_player_hit.play()

func set_slot_display() -> void:
	for i in slots.size():
		if slots[i] == -1: temp_octagon_display[i].visible = false
		else: temp_octagon_display[i].visible = true

func set_slot_active_display(hand: int) -> void:
	for i in slots.size():
		if slots[i] == hand: temp_octagon_display[i].modulate = Color(1.0, 0.767, 0.0)
		else: temp_octagon_display[i].modulate = Color(1.0, 1.0, 1.0)


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

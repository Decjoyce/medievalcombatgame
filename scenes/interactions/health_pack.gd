extends Interactable

func interact_begin(entity: Entity, hand: int):
	if !can_interact: return
	super(entity, hand)
	entity.stance.stats.heal(500)
	queue_free()

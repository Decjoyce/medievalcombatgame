extends Interactable

func interact(entity: Entity):
	if !can_interact: return
	super(entity)
	entity.stance.stats.heal(500)
	queue_free()

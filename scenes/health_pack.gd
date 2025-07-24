extends Interactable

func interact(entity: Entity):
	super(entity)
	entity.stance.stats.heal(500)
	queue_free()

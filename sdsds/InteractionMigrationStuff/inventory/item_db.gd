extends Node

const ICON_PATH = "res://sdsds/InteractionMigrationStuff/inventory/inv_icons/" 	# Change to export
const OBJ_PATH = "res://sdsds/interactableobjs/" 	# Change to export
const ITEMS = {
	"sword": {
		"icon": ICON_PATH + "sword.png",
		"dimensions": Vector2(32, 128),
		"slot": "WEAPON",
		"object": OBJ_PATH + "interactable_torch.tscn"
	},
	"breastplate":{
		"icon": ICON_PATH + "breastplate.png",
		"dimensions": Vector2(64, 128),
		"slot": "CHEST",
		"object": OBJ_PATH + "interactable_torch.tscn"
	},
	"potato":{
		"icon": ICON_PATH + "potato.png",
		"dimensions": Vector2(32, 32),
		"slot": "NONE",
		"object": OBJ_PATH + "interactable_torch.tscn"
	},
	"torch":{
		"icon": ICON_PATH + "torch.png",
		"dimensions": Vector2(32, 128),
		"slot": "NONE",
		"object": OBJ_PATH + "interactable_torch.tscn"
	},
	"_error":{
		"icon": ICON_PATH + "error.png",
		"dimensions": Vector2(32, 32),
		"slot": "NONE",
		"object": OBJ_PATH + "interactable_torch.tscn"
	}
}

func get_item(item_id):
	if item_id in ITEMS:
		return ITEMS[item_id]
	else:
		return ITEMS["_error"]

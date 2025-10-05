extends Node

const ICON_PATH = "res://assets/inv_icons/" 	# Change to export
const ITEMS = {
	"sword": {
		"icon": ICON_PATH + "sword.png",
		"slot": "WEAPON"
	},
	"breastplate":{
		"icon": ICON_PATH + "breastplate.png",
		"slot": "CHEST"
	},
	"potato":{
		"icon": ICON_PATH + "potato.png",
		"slot": "NONE"
	},
	"_error":{
		"icon": ICON_PATH + "error.png",
		"slot": "NONE"
	}
}

func get_item(item_id):
	if item_id in ITEMS:
		return ITEMS[item_id]
	else:
		return ITEMS["_error"]

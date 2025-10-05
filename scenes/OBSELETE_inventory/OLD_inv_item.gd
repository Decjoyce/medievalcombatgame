extends Node2D

@onready var icon_rect_path = $icon

var item_ID : int
var item_grids := []
var selected := false
var grid_anchor = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func load_item(a_itemID : int) -> void:
	var icon_path = "res://assets/" + Inv_DataHandler.item_data[str(a_itemID)]["Name"] + ".png"
	icon_rect_path.texture = load(icon_path)
	for grid in Inv_DataHandler.item_grid_data[str(a_itemID)]:
		var converter_array := []
		for i in grid:
			converter_array.push_back(int(i))
		item_grids.push_back(converter_array)

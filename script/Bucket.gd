extends Sprite2D
class_name Bucket

var hovered_cell: BucketCell = null
var contents: Array = [
	[null, null, null, null, null],
	[null, null, null, null, null],
	[null, null, null, null, null],
	[null, null, null, null, null],
	[null, null, null, null, null]
]
var origin: Array = [
	[false, false, false, false, false],
	[false, false, false, false, false],
	[false, false, false, false, false],
	[false, false, false, false, false],
	[false, false, false, false, false]
]
@onready var main = get_tree().get_root().get_node("main")
var activeMenuFish: MenuFish = null

const size_to_mouse_offset: Dictionary = {
	FishData.Size.SMALL : Vector2(-10, -10),
	FishData.Size.MEDIUM : Vector2(-20, -20),
	FishData.Size.LARGE : Vector2(-30, -30),
}

func _process(_delta):
	if activeMenuFish == null:
		return
	if hovered_cell != null:
		activeMenuFish.position = hovered_cell.position + Vector2(-2, -2)
	else:
		activeMenuFish.global_position = get_viewport().get_mouse_position() + size_to_mouse_offset[activeMenuFish.data.size]

func onCellClicked():
	if activeMenuFish == null:
		return
	if hovered_cell == null:
		return
	var num = 1 if activeMenuFish.data.size == FishData.Size.SMALL else 2 if activeMenuFish.data.size == FishData.Size.MEDIUM else 3
	for y in range(num):
		for x in range(num):
			contents[hovered_cell.y + y][hovered_cell.x + x] = activeMenuFish
			origin[hovered_cell.y + y][hovered_cell.x + x] = false
	origin[hovered_cell.y][hovered_cell.x] = true

	activeMenuFish.mouse_entered.connect(activeMenuFish.on_hovered)
	activeMenuFish.mouse_exited.connect(activeMenuFish.on_unhovered)
	activeMenuFish.gui_input.connect(activeMenuFish._on_gui_input)
	activeMenuFish.mouse_filter = Control.MOUSE_FILTER_PASS
	remove_child(activeMenuFish)
	activeMenuFish.position = Vector2(-2, -2)
	activeMenuFish.origin_cell = hovered_cell
	activeMenuFish = null
	refresh_bucket()
	print("click!")	

func open():
	get_parent().get_node("buttons").hide()
	show()

func close():
	get_parent().get_node("buttons").show()
	hide()

func _on_back_mouse_entered():
	if activeMenuFish == null:
		return
	$back.get_node("Warning").visible = true

func _on_back_mouse_exited():
	$back.get_node("Warning").visible = false

func hover_cell(cell: BucketCell):
	if activeMenuFish:
		if activeMenuFish.data.size == FishData.Size.LARGE:
			for y in range(-1, 2):
				for x in range(-1, 2):
					if cell.y + y < 0 || cell.x + x < 0 || cell.y + y >= contents.size() || cell.x + x >= contents[y].size() || contents[cell.y + y][cell.x + x] != null:
						cancel_hover()
						return
			hovered_cell = $Grid.get_node(str(cell.x - 1) + str(cell.y - 1))
			return
		var num = 1 if activeMenuFish.data.size == FishData.Size.SMALL else 2 
		for y in range(num):
			for x in range(num):
				if cell.y + y >= contents.size() || cell.x + x >= contents[y].size() || contents[cell.y + y][cell.x + x] != null:
					cancel_hover()
					return
	hovered_cell = cell

func cancel_hover():
	hovered_cell = null

func refresh_bucket():
	for y in range(5):
		for x in range(5):
			if contents[y][x] != null && origin[y][x] == true && contents[y][x].get_parent() == null:
				var fish = contents[y][x]
				fish.show_bg()
				$Grid.add_child(fish)
				fish.position = $Grid.get_node(str(x) + str(y)).position + Vector2(-2, -2)
				fish.z_index = x + y
func clicked(x: int, y: int):
	if activeMenuFish != null:
		return
	if contents[y][x] == null:
		return
	activeMenuFish = contents[y][x]
	activeMenuFish.z_index = 20
	$Grid.remove_child(activeMenuFish)
	self.add_child(activeMenuFish)
	activeMenuFish.hide_bg()
	activeMenuFish.global_position = get_viewport().get_mouse_position() + size_to_mouse_offset[activeMenuFish.data.size]
	activeMenuFish.mouse_entered.disconnect(activeMenuFish.on_hovered)
	activeMenuFish.gui_input.disconnect(activeMenuFish._on_gui_input)
	activeMenuFish.mouse_exited.disconnect(activeMenuFish.on_unhovered)
	activeMenuFish.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var num = 1 if activeMenuFish.data.size == FishData.Size.SMALL else 2 if activeMenuFish.data.size == FishData.Size.MEDIUM else 3
	for yy in range(num):
		for xx in range(num):
			contents[y + yy][x + xx] = null
			origin[y + yy][x + xx] = false

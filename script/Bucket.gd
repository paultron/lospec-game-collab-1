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
@onready var main = get_tree().get_root().get_node("main")
var activeMenuFish: MenuFish = null

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if activeMenuFish == null:
		return
	if hovered_cell != null:
		activeMenuFish.position = hovered_cell.position
	else:
		activeMenuFish.global_position = get_viewport().get_mouse_position()

func onCellClicked():
	if activeMenuFish == null:
		return
	contents[hovered_cell.y][hovered_cell.x] = activeMenuFish
	remove_child(activeMenuFish)
	activeMenuFish.position = Vector2(0, 0)
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
	if contents[cell.y][cell.x] != null:
		cancel_hover()
	else:
		hovered_cell = cell

func cancel_hover():
	hovered_cell = null

func refresh_bucket():
	for y in range(5):
		for x in range(5):
			if contents[y][x] != null && $Grid.get_node(str(x) + str(y)).get_children().size() == 0:
				
				$Grid.get_node(str(x) + str(y)).add_child(contents[y][x])
			else:
				for child in $Grid.get_node(str(x) + str(y)).get_children():
					child.queue_free()
func clicked(x: int, y: int):
	print("Check 1")
	if contents[y][x] == null:
		return
	print("Check 2")
	$Grid.get_node(str(x) + str(y)).remove_child(contents[y][x])
	self.add_child(contents[y][x])
	activeMenuFish = contents[y][x]
	contents[y][x] = null

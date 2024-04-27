extends MarginContainer
class_name MenuFish

const size_to_texture: Dictionary = {
	FishData.Size.SMALL: 	"res://art/ui/bucket/bucket-fish-bg-small.png",
	FishData.Size.MEDIUM: 	"res://art/ui/bucket/bucket-fish-bg-medium.png",
	FishData.Size.LARGE: 	"res://art/ui/bucket/bucket-fish-bg-large.png",
}

const top_margin: Dictionary = {
	FishData.Size.SMALL: 	2,
	FishData.Size.MEDIUM: 	4,
	FishData.Size.LARGE: 	6,
}

const bottom_margin: Dictionary = {
	FishData.Size.SMALL: 	3,
	FishData.Size.MEDIUM: 	5,
	FishData.Size.LARGE: 	7,
}

const left_margin: Dictionary = {
	FishData.Size.SMALL: 	2,
	FishData.Size.MEDIUM: 	4,
	FishData.Size.LARGE: 	6,
}

const right_margin: Dictionary = {
	FishData.Size.SMALL: 	3,
	FishData.Size.MEDIUM: 	5,
	FishData.Size.LARGE: 	7,
}

var data: FishData
var origin_cell: BucketCell = null

func populate(initialData: FishData):
	self.data = initialData
	$margin.get_node("margin").get_node("texture").texture = data.sprite
	$margin.get_node("margin").add_theme_constant_override("margin_top", top_margin[data.size])
	$margin.get_node("margin").add_theme_constant_override("margin_bottom", bottom_margin[data.size])
	$margin.get_node("margin").add_theme_constant_override("margin_left", left_margin[data.size])
	$margin.get_node("margin").add_theme_constant_override("margin_right", right_margin[data.size])
	$margin.get_node("bg").texture = load(size_to_texture[data.size])
func on_hovered():
	$hover.show()
	get_parent().get_parent().cancel_hover()

func on_unhovered():
	$hover.hide()

func _on_gui_input(event: InputEvent):	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if origin_cell:
				get_parent().get_parent().clicked(origin_cell.x, origin_cell.y)
			
func show_bg():
	$margin.get_node("bg").show()

func hide_bg():
	$margin.get_node("bg").hide()

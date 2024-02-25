extends TextureRect
class_name MenuFish

const name_to_texture: Dictionary = {
	"Shrimpo" : preload("res://art/fish/shrimpo.png"),
}

var data: FishData

func populate(initialData: FishData):
	self.data = initialData
	texture = name_to_texture[initialData.name]
func on_hovered():
	var parent = get_parent()
	if parent is BucketCell:
		parent._on_mouse_entered()

func _on_gui_input(event: InputEvent):	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var parent = get_parent()
			if parent is BucketCell:
				print("clicked fish")
				parent.get_parent().get_parent().clicked(parent.x, parent.y)
			else:
				print("clicked cell")
				parent.onCellClicked()

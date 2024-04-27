extends Control
class_name BucketCell

@export_range(0, 4) var x: int
@export_range(0, 4) var y: int

func _on_mouse_entered() -> void:
    get_parent().get_parent().hover_cell(self)
func on_click(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        get_parent().get_parent().onCellClicked()


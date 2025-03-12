extends AnimatedSprite2D


func _ready() -> void:
    play("default")
    
    # play default on any children
    for child in get_children():
        if child is AnimatedSprite2D:
            child.play("default")

# destroy self after animation finishes
func _on_AnimatedSprite2D_animation_finished():
    queue_free()
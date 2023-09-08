extends Sprite2D

class_name Fish

@export var data: FishData
var lastMoved: int = 0
var state: State = State.idle

enum State { idle, swimLeft, swimRight}


func _process(delta: float):
    if position.x < -20 or position.x > 280:
        queue_free()
    if Time.get_ticks_msec() - lastMoved > 1000:
        lastMoved = Time.get_ticks_msec()
        if state == State.idle and randf() > 0.5:
            if randf() > 0.5:
                flip_h = true
                state = State.swimRight
            else:
                flip_h = false
                state = State.swimLeft
        elif randf() > 0.2:
            state = State.idle
        
            
    if state == State.swimLeft:
        position.x -= 10 * delta
    elif state == State.swimRight:
        position.x += 10 * delta
extends Sprite2D

class_name Fish

@export var data: FishData
var lastMoved: int = 0
var state: State = State.idle
var attraction: Node2D = null

enum State { idle, swimLeft, swimRight, attracted, hooked}
enum HookState { struggle, rest, caught}


func _process(delta: float):
    if state == State.hooked:
        global_position = attraction.global_position
        return
    if position.x < -20 or position.x > 280:
        queue_free()
    if state == State.attracted:
        # Get direction to attraction
        var dir = (attraction.global_position - global_position).normalized()
        if dir.x < 0:
            flip_h = false
        else:
            flip_h = true
        position += dir * 10 * delta
        if global_position.distance_to(attraction.global_position) < 2:
            bite()
        return
    if Time.get_ticks_msec() - lastMoved > 3000:
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

func on_awareness_entered(other: Area2D):
    if state == State.hooked:
        return
    if other.get_parent() is Fish:
        # swim away from the other fish
        if other.position.x > position.x:
            state = State.swimLeft
            flip_h = false
        else:
            state = State.swimRight
            flip_h = true
    elif other.get_parent().name == "LineEnd" and other.get_parent().get_parent().hooked == null:
        print("attracted")
        # swim towards the line end
        state = State.attracted
        attraction = other
        flip_h = false
    else:
        state = State.idle

func bite():
    print("HIT!")
    state = State.hooked
    attraction.get_parent().get_parent().hooked = self
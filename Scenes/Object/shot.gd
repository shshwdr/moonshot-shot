extends Area2D


onready var timer = $Timer
var move_dir = Vector2.UP
func index_position():
	return Utils.position_to_index(position)

func move():
	timer.start()
	yield(timer, "timeout")
	Utils.move_position_by(self,move_dir)
	if index_position() == Utils.moon.index_position():
		Utils.moon.get_shot()
	pass

	
func _ready():
	timer.wait_time = Utils.wait_time
	while true:
		yield(move(),"completed")
		#check collision
		#check out of screen
		if not Utils.in_screen(index_position()):
			queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

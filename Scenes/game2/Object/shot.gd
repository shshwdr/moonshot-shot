extends Area2D


onready var timer = $Timer
var move_dir = Vector2.UP
var is_shot = false
func index_position():
	return Utils.position_to_index(position)

func move():
	timer.start()
	yield(timer, "timeout")
	Utils.move_position_by(self,move_dir)

	
func _ready():
	timer.wait_time = Utils.wait_time
	while true:
		yield(move(),"completed")
		#check collision
		#check out of screen
		if not Utils.in_screen(index_position()):
			queue_free()

func _process(delta):
	pass
#	if not is_shot:
#		if overlaps_area(Utils.moon):
#			is_shot = true
#			Utils.moon.get_shot()
#			queue_free()
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Shot_area_entered(area):
	if not is_shot and area == Utils.moon:
		is_shot = true
		Utils.moon.get_shot()
		queue_free()

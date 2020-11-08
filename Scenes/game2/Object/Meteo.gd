extends Area2D


onready var timer = $Timer
var move_dir = Vector2.DOWN
var is_shot = false
func index_position():
	return Utils.position_to_index(position)

func move():
	timer.start()
	yield(timer, "timeout")
	Utils.move_position_by(self,move_dir)
#	if Utils.maingame.has_occupied(index_position()):
#		var human = Utils.maingame.index_to_human_map[index_position()]
#		human.damage(1)
#		#Utils.maingame.remove_occupy(index_position())
#		queue_free()
#	pass

	
func _ready():
	timer.wait_time = Utils.wait_time
	while true:
		yield(move(),"completed")
		#check collision
		#check out of screen
		if not Utils.in_screen(index_position()):
			queue_free()


func _on_Moon_area_entered(area):
	print(area, " ", area.is_in_group("human"))
	if not is_shot and area.is_in_group("human"):
		is_shot = true
		area = Utils.maingame.get_above_human_if_existed(area)
		area.damage(1)
		queue_free()

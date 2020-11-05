
extends Area2D

class_name Human

onready var sprite = $Sprite
onready var timer = $Timer

func init(_index):
	pass
	

func move_up():
	timer.start()
	yield(timer, "timeout")
	Utils.move_position_by(self,Vector2.UP)
	pass

func index_position():
	return Utils.position_to_index(position)

func _ready():
	timer.wait_time = Utils.wait_time
	while Utils.maingame.has_occupied(index_position()):
		yield(move_up(),"completed")
	sprite.frame = 1
	sprite.self_modulate = Color(0.5,0.5,0.5,1)
	Utils.maingame.occupy(index_position(),self)
	pass

func _process(delta):
	var index_below = index_position() + Vector2.DOWN
	if Utils.in_screen(index_below) and not Utils.maingame.has_occupied(index_below):
		Utils.maingame.change_occupy(index_position(),index_below)
		Utils.move_position_by(self,Vector2.DOWN)
		
	

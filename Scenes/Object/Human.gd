
extends Area2D


onready var sprite = $Sprite
onready var timer = $Timer

var is_moving = true

func init(_index):
	pass
	

func move_up():
#	timer.start()
#	yield(timer, "timeout")
	yield(Utils.move_position_by(self,Vector2.UP),"completed")
	pass

func index_position():
	return Utils.position_to_index(position)

func _ready():
	timer.wait_time = Utils.wait_time
	while Utils.maingame.has_occupied(index_position()):
		yield(move_up(),"completed")
	is_moving = false
	sprite.frame = 1
	sprite.self_modulate = Color(0.5,0.5,0.5,1)
	Utils.maingame.occupy(index_position(),self)
	pass

func _process(delta):
	if not is_moving:
		var index = index_position()
		var index_below = index + Vector2.DOWN
		if Utils.in_screen(index_below) and not Utils.maingame.has_occupied(index_below):
			is_moving = true
			Utils.maingame.change_occupy(index,index_below)
			yield(Utils.move_position_by(self,Vector2.DOWN),"completed")
			is_moving = false
		
	

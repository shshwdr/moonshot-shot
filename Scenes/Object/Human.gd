
extends Area2D
onready var sprite = $Sprite
onready var timer = $Timer

func init(_index):
	pass

func move_up():
	timer.start()
	yield(timer, "timeout")
	Utils.position_move_by(self,Vector2.UP)
	pass

func index_position():
	return Utils.position_to_index(position)

func _ready():
	while Utils.maingame.has_occupied(index_position()):
		yield(move_up(),"completed")
	sprite.frame = 1
	Utils.maingame.occupy(index_position(),self)
	pass


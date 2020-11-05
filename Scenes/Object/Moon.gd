extends Area2D

onready var timer = $Timer

var move_dir = Vector2.RIGHT
func index_position():
	return Utils.position_to_index(position)

func move():
	timer.start()
	yield(timer, "timeout")
	Utils.position_move_by(self,move_dir)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var index_position = Vector2(0,0)
	position = Utils.index_to_position(index_position)
	while true:
		print(position,index_position())
		yield(move(),"completed")
		if Utils.on_border(index_position()):
			move_dir = -move_dir
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

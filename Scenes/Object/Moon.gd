extends Area2D

onready var timer = $Timer
onready var sprite = $Sprite
var meteo_scene = preload("res://Scenes/Object/Meteo.tscn")

var move_dir = Vector2.RIGHT
func index_position():
	return Utils.position_to_index(position)

func move():
	Utils.move_position_by(self,move_dir)
	
	timer.start()
	yield(timer, "timeout")
	pass

func shoot():
	var meteo_instance = meteo_scene.instance()
	meteo_instance.position = position
	Utils.maingame.bullets.add_child(meteo_instance)
	timer.start()
	yield(timer, "timeout")
	pass

func get_shot():
	sprite.self_modulate = Color(1,0,0,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	Utils.moon = self
	timer.wait_time = Utils.wait_time
	var index_position = Vector2(0,0)
	position = Utils.index_to_position(index_position)
	while true:
		#print(position,index_position())
		yield(move(),"completed")
		
		if Utils.on_border(index_position()):
			move_dir = -move_dir
#		while Utils.maingame.has_column_occupied(index_position()):
#			yield(shoot(),"completed")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

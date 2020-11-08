extends Area2D

onready var timer = $Timer
onready var sprite = $Sprite
onready var tween = $Tween
onready var faceResetTimer = $FaceResetTimer
var meteo_scene = preload("res://Scenes/game2/Object/Meteo.tscn")
var target_index_position
var move_dir = Vector2.RIGHT

var drunk_level = 0

func index_position():
	return Utils.position_to_index(position)

func move():
	yield(Utils.move_position_by(self,move_dir,0.2),"completed")
	pass

func shoot():
	sprite.frame = 3
	faceResetTimer.wait_time = 0.2
	faceResetTimer.start()
	var meteo_instance = meteo_scene.instance()
	meteo_instance.position = Utils.index_to_position( target_index_position)
	Utils.maingame.bullets.add_child(meteo_instance)
	timer.start()
	yield(timer, "timeout")
	pass

func get_shot():
	sprite.self_modulate = Color(1,0,0,1)
	timer.wait_time = Utils.wait_time*3

# Called when the node enters the scene tree for the first time.
func _ready():
	Utils.moon = self
	timer.wait_time = Utils.wait_time
	var index_position = Utils.screen_start_vector
	position = Utils.index_to_position(index_position)
	while true:
		#print(position,index_position())
		yield(move(),"completed")
		
		if Utils.on_border(index_position()):
			move_dir = -move_dir
		
		target_index_position = index_position()#+Vector2(1,0)
		var column_occupied = Utils.maingame.column_occupied_count(target_index_position)
		for i in range(column_occupied):
			yield(shoot(),"completed")
			break
		#detect if more targets spawned
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BlinkTimer_timeout():
	sprite.frame = 1
	faceResetTimer.wait_time = 0.1
	faceResetTimer.start()


func _on_FaceResetTimer_timeout():
	sprite.frame = 0

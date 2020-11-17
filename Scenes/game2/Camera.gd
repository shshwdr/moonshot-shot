extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var move_dir = Vector2.RIGHT

onready var timer_shake_length = $timer_shake_length
onready var timer_wait_times = $timer_wait_times
onready var tween_shake = $tween_camera_shake
onready var flash_image = $flash_sprite

var reset_speed = 0
var strength = 0
var doing_shake = false

func move():
	yield(Utils.move_position_by(self,move_dir,0.3),"completed")
	pass

func reset_camera():
	tween_shake.interpolate_property(self,"offset",offset, Vector2(0,0),reset_speed,Tween.TRANS_SINE,Tween.EASE_OUT)
	tween_shake.start()

func timeout_shake_length():
	doing_shake = false
	reset_camera()
	
#This function does the tween shaking between intervals
func timeout_wait_times():
	if(doing_shake):
		tween_shake.interpolate_property(self,"offset",offset, Vector2(rand_range(-strength,strength),rand_range(-strength,strength)),reset_speed,Tween.TRANS_SINE,Tween.EASE_OUT)
		tween_shake.start()

# Called when the node enters the scene tree for the first time.
func _ready():
	Utils.camera = self
	
func start_shake(time_of_shake,speed_of_shake,strength_of_shake):
	doing_shake = true
	strength = strength_of_shake
	reset_speed = speed_of_shake
	timer_shake_length.start(time_of_shake)
	timer_wait_times.start(speed_of_shake)
	
#This is our flash tween, we tween up, then once we reach up, yield will fire, and we'll tween back down
func start_flash(time,strength):
	tween_shake.interpolate_property(flash_image,"modulate:a",0,strength,time,Tween.TRANS_SINE,Tween.EASE_OUT)
	tween_shake.start()
	
	yield(get_tree().create_timer(time),"timeout")
	tween_shake.interpolate_property(flash_image,"modulate:a",strength,0,time,Tween.TRANS_SINE,Tween.EASE_OUT)
	tween_shake.start()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

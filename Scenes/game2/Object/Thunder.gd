extends Node2D


onready var thunder = $thunder
onready var warning = $warning


var blocker = null

onready var wait_time = 10
var thunder_height = 320

func start_thunder(height):
	warning.visible = false
	thunder.visible = true
	thunder.visible = true
	
	$AnimationPlayer.stop()
	thunder.play()
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# (64, 320)
	thunder.visible = false
	warning.visible = true
	$AnimationPlayer.stop()
	$AnimationPlayer.current_animation = "warning"
	$AnimationPlayer.play()
	#print("get_size ",thunder.frames.get_frame("default",0).get_size())
	#print("get_extent ",thunder.texture.get_size())
	
	scale.y = (Utils.height_total*Utils.tile_length)/float(thunder_height)
	
	yield(get_tree().create_timer(wait_time), "timeout")

#get blocker
#get height
	var height = 1
	if not blocker:
		pass
	start_thunder(height)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_thunder_animation_finished():
	queue_free()
	pass # Replace with function body.
	
func index_position():
	return Utils.position_to_index(position)

func _on_thunder_frame_changed():
	if thunder.frame == 1:
		Utils.camera.start_flash(0.15,0.8)
		#flash the whole game
	elif thunder.frame == 3:
		#destroy everyone on top of blocker
		Utils.maingame.thunder_on_column(index_position())

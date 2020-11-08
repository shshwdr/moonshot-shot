extends Human

onready var shot_sprite = $shotSprite
onready var anim = $shotSprite/AnimationPlayer
var shoter_health = 2
var shot_scene = preload("res://Scenes/game2/Object/shot.tscn")

var make_shot_time = 1
var current_make_time = 0

func _ready():
	._ready()
	health = shoter_health

func _process(delta):
	._process(delta)
	
	if is_shot_ready():
		shot_sprite.rotation_degrees = 0
		anim.play("ready")
		return
	if is_stoping:
		if anim.current_animation != "loading":
			anim.play("loading")
		current_make_time+=delta

func is_shot_ready():
	return current_make_time >= make_shot_time
	
func shot():
	
	current_make_time = 0
	var shot_instance = shot_scene.instance()
	shot_instance.position = Utils.index_to_position(index_position())
	get_parent().add_child(shot_instance)
		
func get_input():
	.get_input()
	if Utils.is_main_game_started:
		if not in_game_screen():
			return
		if is_stoping and current_make_time >= make_shot_time:
			if Input.is_action_pressed(Utils.interact_key_2):
				print("interact key 2 pressed")
				shot()
				
	
	

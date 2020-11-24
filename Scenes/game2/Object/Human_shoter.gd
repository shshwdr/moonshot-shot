extends Human

onready var shot_sprite = $shotSprite
onready var anim = $shotSprite/AnimationPlayer
var shoter_health = 2
var shot_scene = preload("res://Scenes/game2/Object/shot.tscn")

var make_shot_time = 2
var current_make_time = 0

var failed_shoot = false
var is_ready_shoot = false

func _ready():
	._ready()
	max_health = shoter_health
	health = shoter_health

func _process(delta):
	._process(delta)
	
	if is_shot_ready():
		is_ready_shoot = true;
		shot_sprite.rotation_degrees = 0
		anim.play("ready")
		return
	if is_stoping:
		if anim.current_animation != "loading":
			anim.play("loading")
		current_make_time+=delta
		is_ready_shoot = false

func is_shot_ready():
	var temp_make_shot_time = 0.1 if DebugSetting.skip_make_shot_time else make_shot_time
	return current_make_time >= temp_make_shot_time
	


func shot():
	
	current_make_time = 0
	var shot_instance = shot_scene.instance()
	shot_instance.position = Utils.index_to_position(index_position())
	get_parent().call_deferred("add_child",shot_instance)
	is_ready_shoot = false
		
func get_input():
	.get_input()
	if Utils.is_main_game_started:
		if not in_game_screen():
			return
		if is_stoping:
			if Input.is_action_just_pressed(Utils.interact_key_2):
				if is_shot_ready():
					#print("interact key 2 pressed")
					failed_shoot = false
					shot()
				else:
					#play shot waste anim
					current_make_time = 0
					anim.play("loading")
					failed_shoot = true
					yield(get_tree().create_timer(make_shot_time), "timeout")
					failed_shoot = false
				
	
	

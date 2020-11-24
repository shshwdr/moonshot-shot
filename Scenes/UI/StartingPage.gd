extends Control

var level_selection_scene = preload("res://Scenes/UI/LevelSelection.tscn")
onready var advertise = $Node/universe
func _ready():
	MusicManager.play_music("start")
	if LevelManager.finished_game:
		advertise.show_moon()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartGame_pressed():
	
	LevelManager.load_level(0)
	Events.emit_signal("game_start")
	
func _on_Continue_pressed():
	Utils.reload_scene(level_selection_scene)

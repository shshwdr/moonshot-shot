extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var one_level_button = preload("res://Scenes/UI/savedLevel.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for level in range(1,LevelManager.unlocked_level+1):
		var one_level_button_instance = one_level_button.instance()
		one_level_button_instance.init(level)
		$VBoxContainer.add_child(one_level_button_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	Events.emit_signal("game_end")

extends Human

var has_shield = true

func can_block_thunder():
	return has_shield

func block_thunder():
	has_shield = false
	$shileld.visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

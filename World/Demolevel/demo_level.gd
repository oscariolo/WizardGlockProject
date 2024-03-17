extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.max_fps = 60


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_respawn_body_entered(body):
	if body.name == "Wizard":
		$Wizard.position = Vector2(578,185)

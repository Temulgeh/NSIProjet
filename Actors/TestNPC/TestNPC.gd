extends AnimatedSprite

export var jsonname = ""
signal StartDialog(jsonname)

var outline_shader: Shader
var outline_material: ShaderMaterial

var can_interract: bool

func _ready():
	playing = true
	outline_shader = preload("res://Shaders/outline.shader")
	outline_material = ShaderMaterial.new()
	outline_material.shader = outline_shader
	# ===TEMPORARY===
	# it will be easier if we switch to a normal sprite with an AnimationPlayer
	# THIS IS TEMPORARY
	var temp_size = Vector2(120, 25) # TEMPORARY!!!
	# ===END OF TEMPORARY===
	outline_material.set_shader_param(
		"texture_size",
		temp_size
	)


func _process(delta):
	if Input.is_action_just_pressed("Interact") and Global.inZone == true and Global.DialogStarted == false:
		Global.emit_signal("StartDialog",jsonname)
	
	# Change conditions for can_interract later
	# i know this code could be simpler but it won't be the same later
	if Global.inZone and not Global.DialogStarted:
		can_interract = true
	else:
		can_interract = false
	
	if can_interract:
		material = outline_material
	else:
		material = null

func _on_Area2D_body_entered(body: Node2D):
	Global.DialogPosition = $Position2D.global_position
	Global.inZone = true

func _on_Area2D_body_exited(area):
	Global.inZone = false


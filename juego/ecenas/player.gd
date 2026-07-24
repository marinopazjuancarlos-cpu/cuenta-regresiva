extends CharacterBody2D

var direccion : Vector2
var doble_clic : int = 0
@export var speed := 50
@onready var agente:NavigationAgent2D = $NavigationAgent2D
var hola : float
var chao : float
func _ready() -> void:
	agente.target_position = direccion

func _input(event: InputEvent) -> void:

	if event.is_action_pressed("click"):
		
		
		direccion = get_global_mouse_position()
		agente.set_pathfinding_algorithm(0)
		agente.target_position = direccion
func _physics_process(delta: float) -> void:
	if agente.is_target_reached():
		velocity = Vector2.ZERO
		$AnimatedSprite2D.stop()
	else:
		$AnimatedSprite2D.play("caminar")
		if velocity.x > 0:
			$AnimatedSprite2D.flip_h = false
		else: 
			$AnimatedSprite2D.flip_h = true
		var dir:= to_local(agente.get_next_path_position()).normalized()
		velocity = velocity.lerp(dir * speed, delta)
	move_and_slide()
	if doble_clic >= 3:
		get_tree().change_scene_to_file("res://agregar/hojas.tscn")



func _on_button_pressed() -> void:
	
	if doble_clic ==0:
		hola = Time.get_ticks_msec()
		doble_clic +=1
	elif (Time.get_ticks_msec() - chao )< 600 and doble_clic >=2 :
		doble_clic +=1
	else:
		chao = 0
		hola = 0
		doble_clic =0
		print("aaaaaaaaaaase ACABO no puedes hacer doble clic")
		


func _on_button_button_up() -> void:
	chao = Time.get_ticks_msec()
	if (hola - chao ) < 300 and hola != 0:
		doble_clic +=1
		
	else:
		chao = 0
		hola = 0

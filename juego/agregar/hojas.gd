extends Node2D




@onready var hoja1 = $hoja1
@onready var hoja2 = $hoja2
@onready var hoja3 = $hoja3
var hoja1_cayendo = false
var hoja2_cayendo = false
var hoja3_cayendo = false
var velocidad = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var nivel1 = get_tree().get_nodes_in_group("pantalla")[0]
	$hoja1/Timer1.wait_time = float(randi_range(0,2))
	
	
	$hoja1/Timer1.start()
	$hoja2/Timer2.start()
	$hoja3/Timer3.start()
	$AnimatableBody2D.constant_linear_velocity.y = 0.0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$hoja1.velocity.x=0
	hoja1.position.y += velocidad
	
	
	
	
	
	
	
	
	if hoja1.position.y > 130:
		hoja1_cayendo = true
	#elif hoja1.position.y <= 269:
		
	elif hoja1_cayendo == true and $hoja1/hoja1.visible == true:
		velocidad = 2
		
	if hoja2.position.y > 130:
		hoja2_cayendo = true
	elif hoja2_cayendo == true and $hoja2/hoja2.visible == true:
		velocidad = 2
		hoja2.position.y +=velocidad
	elif hoja2_cayendo ==false and hoja2.position.y <= -130:
		print("dddddddddddddddddddddddddddd")
	
	if hoja3.position.y > 130:
		hoja3_cayendo = true
	elif hoja3_cayendo == true and $hoja3/hoja3.visible == true:
		velocidad = 2
		hoja3.position.y +=velocidad
	elif hoja3_cayendo ==false and hoja3.position.y == -130:
		print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
	
		
	$Tiempo.text = str(int($Tiempo_restante.time_left))
	hoja1.move_and_slide()
	hoja2.move_and_slide()
	hoja3.move_and_slide()
		




func _on_timer_timeout() -> void:
	if $hoja1/hoja1.visible != true :
		$hoja1/hoja1.visible = true
		hoja1_cayendo = true
		
	

	#$hoja1/Timer.start()


func _on_timer_2_timeout() -> void:
	if $hoja2/hoja2.visible != true :
		$hoja2/hoja2.visible = true
		hoja2_cayendo = true
	
	


func _on_timer_3_timeout() -> void:
	if $hoja3/hoja3.visible != true :
		$hoja3/hoja3.visible = true
		hoja3_cayendo = true
		
	

	



func _on_hoja_1_pressed() -> void:
	$AnimatableBody2D/CollisionShape2D.disabled = false
	$AnimatableBody2D.constant_linear_velocity.y = -200.0
	
	


func _on_hoja_2_pressed() -> void:
	$AnimatableBody2D2/CollisionShape2D2.disabled = false
	$AnimatableBody2D2.constant_linear_velocity.y = -200.0
	
	
	#velocidad = -2
	#hoja2_cayendo = false
	
	
	



func _on_hoja_3_pressed() -> void:
	hoja3_cayendo = false




func _on_tiempo_restante_timeout() -> void:
	$Tiempo_restante.stop()
	#PAUSADOR
	get_tree().paused =true


func _on_area_2d_body_entered(body: Node2D) -> void:
	$AnimatableBody2D.constant_linear_velocity.y = 0.0
	$AnimatableBody2D/CollisionShape2D.disabled = true

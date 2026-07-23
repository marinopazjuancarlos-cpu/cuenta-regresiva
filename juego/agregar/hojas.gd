extends Node2D
var velocidad =2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var nivel1 = get_tree().get_nodes_in_group("pantalla")[0]
	$gas1/Timer1.wait_time = float(randi_range(1,3))
	
	#INICIA LOS 3 TIMER
	$gas1/Timer1.start()
	#ENTRE 1-3 SEGUNDOS
	$gas2/Timer2.start()
	#10 SEGUNDOS
	$gas3/Timer3.start()
	#20 SEGUNDOS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	#CAIDA DE HOJAS
	if $gas1/tubo1.visible and $gas1.position.y < 130 :
		$gas1.position.y += 2
		
	if $gas2/tubo2.visible and $gas1.position.y < 130 :
		$gas2.position.y += 2
		
	if $gas3/tubo3.visible and $gas3.position.y < 130 :
		$gas3.position.y += 2
		
		
		
	#DESACTIVACION DEL TRAMPOLIN
	
	#PD: por alguna razon sigue detectando la colision cuando esta desactivado
	#NECESITO QUE ATRAVIESE LAS COLISIONES DEL ANIMATABLE 
	#PARA QUE LAS HOJAS LLEGUEN A LAS COORDENADAS de los characterbody POSITION.Y = -132
	if $AnimatableBody2D/CollisionShape2D.disabled:
		$AnimatableBody2D.constant_linear_velocity.y = 0
		
	
	#CUENTA REGRESIVA
	$Tiempo.text = str(int($Tiempo_restante.time_left))
	#LLAMA LAS FISICAS DESDE ACÁ Y LAS ACTIVA
	$gas1.move_and_slide()
	$gas2.move_and_slide()
	$gas3.move_and_slide()
	



func _on_timer_timeout() -> void:
	#APARICION DE LA PRIMERA HOJA
	if $gas1/tubo1.visible != true :
		$gas1/tubo1.visible = true
		$gas1.velocity.y += 10
		
		



func _on_timer_2_timeout() -> void:
	#APARICION DE LA SEGUNDA HOJA
	if $gas2/tubo2.visible != true :
		$gas2/tubo2.visible = true
	
	


func _on_timer_3_timeout() -> void:
	#APARICION DE LA TERCERA HOJA
	if $gas3/tubo3.visible != true :
		$gas3/tubo3.visible = true
	

	


#NECESITO: Cuando se haga CLIC se cambie a la mascara o capa de la hoja 
# para que suba esa hoja suba y las otras sigan cayendo
func _on_tubo_1_pressed() -> void:
	#TOCAR LA HOJA 1 PARA QUE SUBA
	$AnimatableBody2D.constant_linear_velocity.y = -180
	##APARECE EL ANIMATABLE PARA QUE LAS HOJAS (funciona como trampolin)
	$AnimatableBody2D.position.y = $gas1.position.y + 180
	$AnimatableBody2D/CollisionShape2D.disabled = false 
	
	


func _on_tubo_2_pressed() -> void:
	#TOCAR LA HOJA 2 PARA QUE SUBA
	$AnimatableBody2D.constant_linear_velocity.y = -180
	##APARECE EL ANIMATABLE PARA QUE LAS HOJAS (funciona como trampolin)
	#$AnimatableBody2D2.position.y = $gas2.position.y + 110
	$AnimatableBody2D2/CollisionShape2D.disabled = false 


func _on_tubo_3_pressed() -> void:
	#TOCAR LA HOJA 3 PARA QUE SUBA
	$AnimatableBody2D.constant_linear_velocity.y = -180
	$gas3/tubo3.visible = false
	$gas3/Timer3.wait_time = float(randi_range(1,5))
	$gas3/Timer3.start()



func _on_tiempo_restante_timeout() -> void:
	$Tiempo_restante.stop()
	#PAUSADOR
	get_tree().paused =true

#DESACTIVA LA COLISION DEL ANIMATABLE
# (Acá se podria poner el codigo de cambio de mascaras)
func _on_area_2d_body_entered(body: Node2D) -> void:
	$AnimatableBody2D/CollisionShape2D.disabled = true
	
	


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	$AnimatableBody2D/CollisionShape2D.disabled = true


func _on_area_2d_3_body_entered(body: Node2D) -> void:
	$AnimatableBody2D/CollisionShape2D.disabled = true

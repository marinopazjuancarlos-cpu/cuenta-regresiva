extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var nivel1 = get_tree().get_nodes_in_group("pantalla")[0]
	$gas1/Timer1.wait_time = float(randi_range(4,7))
	
	
	$gas1/Timer1.start()
	$gas2/Timer2.start()
	$gas3/Timer3.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	

		
	$Tiempo.text = str(int($Tiempo_restante.time_left))
	




func _on_timer_timeout() -> void:
	if $gas1/tubo1.visible != true :
		$gas1/tubo1.visible = true
		
	

	#$gas1/Timer.start()


func _on_timer_2_timeout() -> void:
	if $gas2/tubo2.visible != true :
		$gas2/tubo2.visible = true
	
	


func _on_timer_3_timeout() -> void:
	if $gas3/tubo3.visible != true :
		$gas3/tubo3.visible = true
	

	



func _on_tubo_1_pressed() -> void:
	$gas1/tubo1.visible = false
	$gas1/Timer1.wait_time = float(randi_range(1,5))
	$gas1/Timer1.start()


func _on_tubo_2_pressed() -> void:
	$gas2/tubo2.visible = false
	$gas2/Timer2.wait_time = float(randi_range(1,5))
	$gas2/Timer2.start()


func _on_tubo_3_pressed() -> void:
	$gas3/tubo3.visible = false
	$gas3/Timer3.wait_time = float(randi_range(1,5))
	$gas3/Timer3.start()



func _on_tiempo_restante_timeout() -> void:
	$Tiempo_restante.stop()
	#PAUSADOR
	get_tree().paused =true

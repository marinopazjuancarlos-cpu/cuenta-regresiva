extends Node2D
#var nivel1 =get_tree().get_nodes_in_group("pantalla")[0]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$gas1/Timer1.wait_time = float(randi_range(4,7))
	$gas1/Timer1.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Tiempo.text = str(int($Tiempo_restante.time_left))
	
	
	
	





func _on_timer_timeout() -> void:
	if $gas1/tubo1.visible != true :
		$gas1/tubo1.visible = true
	


func _on_timer_2_timeout() -> void:
	if $gas2/tubo2.visible != true :
		$gas2/tubo2.visible = true
	
	


func _on_timer_3_timeout() -> void:
	if $gas3/tubo3.visible != true :
		$gas3/tubo3.visible = true
	

	
func _on_timer_4_timeout() -> void:
	if $gas4/tubo4.visible != true :
		$gas4/tubo4.visible = true
	


func _on_timer_5_timeout() -> void:
	if $gas5/tubo5.visible != true :
		$gas5/tubo5.visible = true
	



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


func _on_tubo_4_pressed() -> void:
	$gas4/tubo4.visible = false
	$gas4/Timer4.wait_time = float(randi_range(1,5))
	$gas4/Timer4.start()


func _on_tubo_5_pressed() -> void:
	$gas5/tubo5.visible = false
	$gas5/Timer5.wait_time = float(randi_range(1,5))
	$gas5/Timer5.start()



func _on_tiempo_restante_timeout() -> void:
	$Tiempo_restante.stop()
	#PAUSADOR
	get_tree().paused =true

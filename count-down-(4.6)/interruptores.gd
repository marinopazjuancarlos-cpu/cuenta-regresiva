extends Node2D
#var nivel1 =get_tree().get_nodes_in_group("pantalla")[0]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var a=0 
	
	for interruptor in get_tree().get_nodes_in_group("interruptor"):
		print("assassaad")
		var apagado = randi_range(0,1)
		
		
		if apagado == 1:
			
			interruptor.get_node("tubo").set_visible(true)
			
		else:
			print("noooo")
			

func activar_interruptores():
	var a=0 
	
	for interruptor in get_tree().get_nodes_in_group("interruptor"):
		print("assassaad")
		var apagado = randi_range(0,1)
		
		
		if apagado == 1:
			
			interruptor.get_node("tubo").set_visible(true)
			
		else:
			print("noooo")
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var reset= 0
	$Tiempo.text = str(int($Tiempo_restante.time_left))
	for interruptor in get_tree().get_nodes_in_group("interruptor"):
		if interruptor.get_node("tubo").visible == false:
			reset +=1 
		if reset == 10:
			activar_interruptores()



func _on_tubo_1_pressed() -> void:
	$gas1/tubo.visible = false



func _on_tubo_2_pressed() -> void:
	$gas2/tubo.visible = false



func _on_tubo_3_pressed() -> void:
	$gas3/tubo.visible = false


func _on_tubo_4_pressed() -> void:
	$gas4/tubo.visible = false


func _on_tubo_5_pressed() -> void:
	$gas5/tubo.visible = false
	
func _on_tubo_6_pressed() -> void:
	$gas6/tubo.visible = false
func _on_tubo_7_pressed() -> void:
	$gas7/tubo.visible = false
func _on_tubo_8_pressed() -> void:
	$gas8/tubo.visible = false
func _on_tubo_9_pressed() -> void:
	$gas9/tubo.visible = false
func _on_tubo_10_pressed() -> void:
	$gas10/tubo.visible = false



func _on_tiempo_restante_timeout() -> void:
	$Tiempo_restante.stop()
	#PAUSADOR
	get_tree().paused =true






	


func _on_tubo_pressed() -> void:
	pass # Replace with function body.

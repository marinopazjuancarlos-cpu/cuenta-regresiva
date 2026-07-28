extends Node2D
#var nivel1 =get_tree().get_nodes_in_group("pantalla")[0]
# Called when the node enters the scene tree for the first time.
var puntos : int
const PUNTOS_MINIMOS_FINAL_A = 200
const PUNTOS_MINIMOS_FINAL_B = 100
func _ready() -> void:
	var a=0 
	
	activar_interruptores()

func activar_interruptores():
	var a=0 
	
	for interruptor in get_tree().get_nodes_in_group("interruptor"):
		print("assassaad")
		var apagado = randi_range(0,1)
		
		
		if apagado == 1:
			interruptor.get_node("AnimatedSprite2D").set_frame(1)
			interruptor.get_node("tubo").set_visible(true)
			
		else:
			interruptor.get_node("AnimatedSprite2D").set_frame(0)
			print("noooo")
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$puntos.text =str(puntos)
	var reset= 0
	$Tiempo.text = str(int($Tiempo_restante.time_left))
	for interruptor in get_tree().get_nodes_in_group("interruptor"):
		if interruptor.get_node("tubo").visible == false:
			reset +=1 
		if reset == 10:
			puntos +=10
			activar_interruptores()



func _on_tubo_1_pressed() -> void:
	$palanca.play()
	$gas1/tubo.visible = false
	$gas1/AnimatedSprite2D.set_frame(0)



func _on_tubo_2_pressed() -> void:
	$palanca.play()
	$gas2/tubo.visible = false
	$gas2/AnimatedSprite2D.set_frame(0)



func _on_tubo_3_pressed() -> void:
	$palanca.play()
	$gas3/tubo.visible = false
	$gas3/AnimatedSprite2D.set_frame(0)


func _on_tubo_4_pressed() -> void:
	$palanca.play()
	$gas4/tubo.visible = false
	$gas4/AnimatedSprite2D.set_frame(0)


func _on_tubo_5_pressed() -> void:
	$palanca.play()
	$gas5/tubo.visible = false
	$gas5/AnimatedSprite2D.set_frame(0)
	
func _on_tubo_6_pressed() -> void:
	$palanca.play()
	$gas6/tubo.visible = false
	$gas6/AnimatedSprite2D.set_frame(0)
func _on_tubo_7_pressed() -> void:
	$palanca.play()
	$gas7/tubo.visible = false
	$gas7/AnimatedSprite2D.set_frame(0)
func _on_tubo_8_pressed() -> void:
	$palanca.play()
	$gas8/tubo.visible = false
	$gas8/AnimatedSprite2D.set_frame(0)
func _on_tubo_9_pressed() -> void:
	$palanca.play()
	$gas9/tubo.visible = false
	$gas9/AnimatedSprite2D.set_frame(0)
	
func _on_tubo_10_pressed() -> void:
	$palanca.play()
	$gas10/tubo.visible = false
	$gas10/AnimatedSprite2D.set_frame(0)



func _on_tiempo_restante_timeout() -> void:
	$Tiempo_restante.stop()
	#PAUSADOR
	get_tree().paused =true
	ControladorJuego.terminar_minijuego(puntos, PUNTOS_MINIMOS_FINAL_A, PUNTOS_MINIMOS_FINAL_B)






	


func _on_tubo_pressed() -> void:
	pass # Replace with function body.

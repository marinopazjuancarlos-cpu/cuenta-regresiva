extends Node2D
var puntos: int = 0
@onready var prev_mouse_pos = Vector2(0,0)
@onready var mouse_speed = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
const PUNTOS_MINIMOS_FINAL_A = 100
const PUNTOS_MINIMOS_FINAL_B = 50
const PUNTOS_MINIMOS_FINAL_C= 10

const PATRONES_DIAS = {
	1: {
		
		"tamaño_cara": 0.4,
		

	},
	2: {
		"tamaño_cara":0.6,
		

	},
	3: {
		"tamaño_cara": 0.8,
		
		
		
	},
}

func _ready() -> void:
	
	pass # Replace with function body.
	


func _process(delta):
	$Label.text =str(int(get_node("Tiempo_restante").time_left))
	var current_mouse_pos = get_viewport().get_mouse_position()
	mouse_speed = (current_mouse_pos - prev_mouse_pos) / delta
	prev_mouse_pos = current_mouse_pos
	$Area2D.set_position(get_global_mouse_position()*4)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		
		if mouse_speed.y < 0: 
			
			$Sprite2D.rotation += 10
			$Path2D/PathFollow2D.progress += 10
			
		elif mouse_speed.y > 0:
			$Sprite2D.rotation -= 10
			$Path2D/PathFollow2D.progress -= 10



func _on_tiempo_restante_timeout() -> void:
	$Tiempo_restante.stop()
	$PuntajeTimer.stop()
	ControladorJuego.registrar_puntaje_minijuego(puntos, PUNTOS_MINIMOS_FINAL_A, PUNTOS_MINIMOS_FINAL_B)
	get_tree().paused = true

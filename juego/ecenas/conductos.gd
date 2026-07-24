extends Node2D

var puntos: int = 0
@onready var prev_mouse_pos = Vector2.ZERO
@onready var mouse_speed = Vector2.ZERO

const PUNTOS_MINIMOS_FINAL_A = 100
const PUNTOS_MINIMOS_FINAL_B = 50
const PUNTOS_MINIMOS_FINAL_C = 10

const DURACION_MINIJUEGO = 30.0
const PUNTOS_POR_VUELTA = 10
const INTERVALO_CARA = 10.0
const DURACION_CARA = 2.0
const ADVERTENCIA_CARA = 1.0
const PENALIZACION_CARA = 5

var vueltas: int = 0
var cara_activa: bool = false
var tiempo_cara: float = 0.0
var cara_en_linterna: bool = false
var tiempo_contacto: float = 0.0   

var rotacion_acumulada: float = 0.0

func _ready() -> void:
	$Tiempo_restante.wait_time = DURACION_MINIJUEGO
	$Tiempo_restante.start()
	$CaraTimer.wait_time = INTERVALO_CARA
	$CaraTimer.start()

func _process(delta: float) -> void:
	$Area2D.position = get_global_mouse_position() * 4
	$Label.text = str(int($Tiempo_restante.time_left))
	var current_mouse_pos = get_viewport().get_mouse_position()
	mouse_speed = (current_mouse_pos - prev_mouse_pos) / delta
	prev_mouse_pos = current_mouse_pos

	# Movimiento de la rueda
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if mouse_speed.y < 0:
			$Sprite2D.rotation -= 0.02
			$Path2D/PathFollow2D.progress += 2
			_sumar_rotacion(1)
		elif mouse_speed.y > 0:
			$Sprite2D.rotation -= 0.02
			$Path2D/PathFollow2D.progress += 2
			_sumar_rotacion(1)


	if cara_activa:
		tiempo_cara += delta
		if cara_en_linterna:
			tiempo_contacto += delta
			if tiempo_contacto >= 2.0: 
				puntos -= PENALIZACION_CARA
				tiempo_contacto = 0.0    
				_linterna_alerta()
		if tiempo_cara >= DURACION_CARA:
			_desactivar_cara()

	$Puntos.text = str(int(puntos))

func _sumar_rotacion(grados: float) -> void:
	rotacion_acumulada += abs(grados)
	if rotacion_acumulada >= 360.0:
		rotacion_acumulada = 0.0
		vueltas += 1
		puntos += PUNTOS_POR_VUELTA

func _on_tiempo_restante_timeout() -> void:
	$Tiempo_restante.stop()
	$CaraTimer.stop()
	ControladorJuego.registrar_puntaje_minijuego(puntos, PUNTOS_MINIMOS_FINAL_A, PUNTOS_MINIMOS_FINAL_B)
	get_tree().paused = true

func _on_cara_timer_timeout() -> void:
	_activar_cara()

func _activar_cara() -> void:
	cara_activa = true
	tiempo_cara = 0.0
	tiempo_contacto = 0.0
	$Path2D/PathFollow2D/CharacterBody2D/Sprite2D.visible = true

func _desactivar_cara() -> void:
	cara_activa = false
	$Path2D/PathFollow2D/CharacterBody2D/Sprite2D.visible = false
	tiempo_cara = 0.0
	tiempo_contacto = 0.0
	cara_en_linterna = false
	$Area2D/lin.modulate = Color(1,1,1)

func _linterna_alerta() -> void:
	$Area2D/lin.modulate = Color(1, 0.5, 0.5)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Cara":
		cara_en_linterna = true
		tiempo_contacto = 0.0   

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Cara":
		cara_en_linterna = false
		tiempo_contacto = 0.0   
		$Area2D/lin.modulate = Color(1,1,1)

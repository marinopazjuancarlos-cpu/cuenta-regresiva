extends Node2D
var mouse_dentro = false

var puntos: int = 0
@onready var prev_mouse_pos = Vector2.ZERO
@onready var mouse_speed = Vector2.ZERO
var tiempo_iniciar :float
const PUNTOS_MINIMOS_FINAL_A = 100
const PUNTOS_MINIMOS_FINAL_B = 50
const PUNTOS_MINIMOS_FINAL_C = 10

const DURACION_MINIJUEGO = 30.0
const PUNTOS_POR_VUELTA = 10
const INTERVALO_CARA = 5.0
const DURACION_CARA = 5.0
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
	if tiempo_iniciar == Time.get_ticks_msec() and cara_en_linterna == true:
		$cara.start()
		$cara.autostart = true
	pos_cosas($PointLight2D)
	$Area2D.position = get_global_mouse_position() *4
	$Label.text = str(int($Tiempo_restante.time_left))
	var current_mouse_pos = get_viewport().get_mouse_position()
	mouse_speed = (current_mouse_pos - prev_mouse_pos) / delta
	prev_mouse_pos = current_mouse_pos
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)and mouse_dentro== false :
		if mouse_speed.y < 0 :
			$Sprite2D.rotation -= 0.1
			$Path2D/PathFollow2D.progress += 10
			_sumar_rotacion(1)
		elif mouse_speed.y > 0 :
			$Sprite2D.rotation += 0.1
			$Path2D/PathFollow2D.progress -= 10
			_sumar_rotacion(1)
	if cara_activa:
		tiempo_cara += delta
		if cara_en_linterna:
			tiempo_contacto += delta
			if tiempo_contacto >= 2.0: 
				puntos -= PENALIZACION_CARA
				tiempo_contacto = 0.0    
				
		if tiempo_cara >= DURACION_CARA:
			_desactivar_cara()

	$Puntos.text = str(int(puntos))
func pos_cosas(cosa):
	cosa.position = get_global_mouse_position() * 4
	# Movimiento de la rueda
func _sumar_rotacion(grados: float) -> void:
	rotacion_acumulada += abs(grados*5)
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
	var sprite_cara = $Path2D/PathFollow2D/CharacterBody2D/Sprite2D
	sprite_cara.visible = true
	#APARECE RANDOMENTE
	$Path2D/PathFollow2D.progress = randi()
	
func _desactivar_cara() -> void:
	cara_activa = false
	$Path2D/PathFollow2D/CharacterBody2D/Sprite2D.visible = false
	tiempo_cara = 0.0
	tiempo_contacto = 0.0
	cara_en_linterna = false



func _on_area_2d_body_entered(_body: Node2D) -> void:
	
	if $Path2D/PathFollow2D/CharacterBody2D/Sprite2D.visible :
		tiempo_iniciar = Time.get_ticks_msec() +1000
		cara_en_linterna = true
		
		#$cara.start()
		
		


func _on_area_2d_body_exited(_body: Node2D) -> void:
		cara_en_linterna = false
		tiempo_contacto = 0.0
		$cara.autostart = false
		$cara.stop()

func _on_cara_timeout() -> void:
	puntos -=10
	print(puntos)
	


func _on_button_mouse_entered() -> void:
	mouse_dentro =true
	print(mouse_dentro)


func _on_button_mouse_exited() -> void:
	mouse_dentro = false
	


func _on_button_pressed() -> void:
	pass # Replace with function body.

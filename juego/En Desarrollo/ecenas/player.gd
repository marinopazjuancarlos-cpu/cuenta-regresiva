extends CharacterBody2D

## Velocidad
@export var speed: float = 180.0
## Que tan rápido alcanza velocidad máxima
@export var aceleracion: float = 10.0        
## Que tan rapido frena
@export var frenado: float = 16.0
## Píxeles para considerar que llego
@export var distancia_llegada: float = 8.0   

@onready var agente: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var moviéndose: bool = false

# Doble clic
var doble_clic: int = 0
var tiempo_primer_clic: float = 0.0
var tiempo_soltó: float = 0.0
const VENTANA_DOBLE_CLIC: float = 400.0  # ms

func _ready() -> void:
	agente.target_position = global_position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var destino := get_global_mouse_position()
		agente.target_position = destino
		moviéndose = true


func _physics_process(delta: float) -> void:
	var distancia_al_destino := global_position.distance_to(agente.target_position)

	if moviéndose and not agente.is_navigation_finished():
		var siguiente_punto: Vector2 = agente.get_next_path_position()
		var dir := (siguiente_punto - global_position).normalized()
		var factor_velocidad = clamp(distancia_al_destino / 60.0, 0.15, 1.0)
		var velocidad_objetivo: Vector2 = dir * speed * factor_velocidad
		velocity = velocity.lerp(velocidad_objetivo, aceleracion * delta)

		# Flip con umbral para evitar titilacion
		if abs(velocity.x) > 10.0:
			sprite.flip_h = velocity.x < 0.0

		sprite.play("caminar")

		if distancia_al_destino <= distancia_llegada: _llegar()
	else:
		velocity = velocity.lerp(Vector2.ZERO, frenado * delta)
		if velocity.length() < 2.0:
			velocity = Vector2.ZERO
			if sprite.is_playing(): sprite.stop()

	move_and_slide()

	if doble_clic >= 3: get_tree().change_scene_to_file("uid://c27uvtp7ssdue")


func _llegar() -> void:
	moviéndose = false
	agente.target_position = global_position  # Evita que el agente siga buscando


func _on_button_pressed() -> void:
	var ahora := Time.get_ticks_msec()

	if doble_clic == 0:
		# Primer clic
		tiempo_primer_clic = ahora
		doble_clic = 1
	elif doble_clic == 1 and (ahora - tiempo_primer_clic) < VENTANA_DOBLE_CLIC:
		# Segundo clic dentro de la ventana
		doble_clic = 2
	else:
		# Fuera de tiempo, reiniciar
		doble_clic = 1
		tiempo_primer_clic = ahora


func _on_button_button_up() -> void:
	var ahora := Time.get_ticks_msec()

	if doble_clic == 2:
		tiempo_soltó = ahora
		if (ahora - tiempo_primer_clic) < VENTANA_DOBLE_CLIC:
			doble_clic = 3 
		else:
			doble_clic = 0

extends Area2D
class_name Interactuable
var ventana_abierta = true
var dialogo: int
## Area2D genérico: al hacer clic, el jugador camina hasta "JugadorAlcance"
## y luego se muestra el diálogo asignado.

## Claves de traducción definidas en el CSV (ej. "DIALOGO_CAJA_L1").
@export var lineas: Array[String] = []
@export var una_sola_vez: bool = false

@onready var punto_destino: Marker2D = $JugadorAlcance

var ya_interactuado: bool = false
var secuencia_en_curso: bool = false

func _ready() -> void:
	input_pickable = true
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if secuencia_en_curso or (una_sola_vez and ya_interactuado):
		return
	if event.is_action_pressed("click"):
			
			if ventana_abierta == true:
				if dialogo == 0:
					_iniciar_interaccion()
					_ventana_abierta()
					dialogo +=1
				else:
					_ventana_abierta()
				
			else:
				cerrar_ventana()

func cerrar_ventana():
				$"../AnimatedSprite2D/AudioStreamPlayer2D".stream = preload("uid://dr22th6wsx7k8")
				$"../AnimatedSprite2D/AudioStreamPlayer2D".play()
				$"../AnimatedSprite2D".play_backwards("default")
				ventana_abierta = true

func _ventana_abierta():
				$"../AnimatedSprite2D/AudioStreamPlayer2D".stream = preload("uid://urrv7cy25wv8")
				$"../AnimatedSprite2D/AudioStreamPlayer2D".play()
				$"../AnimatedSprite2D".play("default")
				ventana_abierta = false

func _iniciar_interaccion() -> void:
	secuencia_en_curso = true

	var jugador: Node = get_tree().get_first_node_in_group("player")
	if jugador == null:
		push_error("Interactuable: no se encontró al Player en el grupo 'player'")
		secuencia_en_curso = false
		return

	jugador.mover_a(punto_destino.global_position)
	await jugador.llego_a_destino

	await ControladorDialogo.mostrar_dialogo(lineas)

	ya_interactuado = true
	secuencia_en_curso = false

extends Area2D
class_name Interactuable

## Area2D genérico: al hacer clic, el jugador camina hasta "JugadorAlcance"
## y luego se muestra el diálogo asignado.

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
		_iniciar_interaccion()


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

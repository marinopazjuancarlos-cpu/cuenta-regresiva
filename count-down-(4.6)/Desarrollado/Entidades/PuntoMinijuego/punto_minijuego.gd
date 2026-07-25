extends Area2D

## Punto interactivo en la oficina que inicia un minijuego.
## Solo queda activo cuando dia/indice coinciden con el progreso actual en ControladorJuego.

@export var dia: int = 1
@export var indice: int = 0
@export var escena_minijuego: PackedScene
@export var dialogo_pre: String = ""

@onready var punto_destino: Marker2D = $PuntoDestino

var activo: bool = false
var secuencia_en_curso: bool = false


func _ready() -> void:
	input_pickable = true
	input_event.connect(_on_input_event)
	ControladorJuego.progreso_actualizado.connect(_actualizar_estado)
	_actualizar_estado()


func _actualizar_estado() -> void:
	secuencia_en_curso = false
	activo = escena_minijuego != null \
		and ControladorJuego.dia_actual == dia \
		and ControladorJuego.indice_minijuego_actual == indice
	visible = activo
	monitorable = activo


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not activo or secuencia_en_curso:
		return
	if event.is_action_pressed("click"):
		_iniciar_secuencia()


func _iniciar_secuencia() -> void:
	secuencia_en_curso = true
	activo = false

	var jugador: Node = get_tree().get_first_node_in_group("player")
	if jugador == null:
		push_error("PuntoMinijuego: no se encontró al Player en el grupo 'player'")
		return

	jugador.mover_a(punto_destino.global_position)
	await jugador.llego_a_destino

	var capa: Node = get_tree().get_first_node_in_group("capa_minijuego")
	if capa == null:
		push_error("PuntoMinijuego: no se encontró la capa 'capa_minijuego' en la oficina")
		return

	ControladorJuego.abrir_minijuego(escena_minijuego, capa)

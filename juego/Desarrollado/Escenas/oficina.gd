extends Node2D

const RUTA_CASA = "uid://c5tycjcp8j56r"
const RUTA_VENTILACION = "uid://biilnxqs0ofwg"
const RUTA_CABLES = "uid://wghivwd36qef"

@export var lineas: Array[String] = []
@export var una_sola_vez: bool = false



var ya_interactuado: bool = false
var secuencia_en_curso: bool = false

func _physics_process(delta: float) -> void:
	if ControladorJuego.fin_de_jornada == true:
		if secuencia_en_curso or (una_sola_vez and ya_interactuado):
			return
		_iniciar_interaccion()


func _iniciar_interaccion() -> void:
	secuencia_en_curso = true

	var jugador: Node = get_tree().get_first_node_in_group("player")
	if jugador == null:
		push_error("Interactuable: no se encontró al Player en el grupo 'player'")
		secuencia_en_curso = false
		return

	await ControladorDialogo.mostrar_dialogo(lineas)

	ya_interactuado = true
	secuencia_en_curso = false

# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_area_2d_body_entered(body: Node2D) -> void:
	ControladorTransiciones.ir_a_escena(RUTA_VENTILACION)

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	ControladorTransiciones.ir_a_escena(RUTA_CABLES)

func _on_area_2d_3_body_entered(body: Node2D) -> void:
	if ControladorJuego.fin_de_jornada == true:
		ControladorTransiciones.ir_a_escena(RUTA_CASA)

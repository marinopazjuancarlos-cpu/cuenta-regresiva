extends Node2D

const RUTA_VENTILACION = "uid://biilnxqs0ofwg"
const RUTA_CABLES = "uid://wghivwd36qef"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_area_2d_body_entered(body: Node2D) -> void:
	ControladorTransiciones.ir_a_escena(RUTA_VENTILACION)

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	ControladorTransiciones.ir_a_escena(RUTA_CABLES)

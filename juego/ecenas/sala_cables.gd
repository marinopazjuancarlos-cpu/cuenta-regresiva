extends Node2D

const RUTA_OFICINA = "uid://cfd61lgqbjf37"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_area_2d_body_entered(body: Node2D) -> void:
		ControladorTransiciones.ir_a_escena(RUTA_OFICINA)

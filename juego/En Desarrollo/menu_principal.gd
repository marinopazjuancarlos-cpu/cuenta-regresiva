extends Control


func _on_button_pressed() -> void:
	ControladorTransiciones.ir_a_escena("uid://caxtq16pxthpg", "Continuar donde lo dejaste...[br]No siempre es la mejor idea")
	print("Continuar")


func _on_button_2_pressed() -> void:
	ControladorTransiciones.ir_a_escena("uid://caxtq16pxthpg", "Hay veces en las que debemos dejar ir")
	print("Nueva partida")


func _on_button_3_pressed() -> void:
	print("Creditos")

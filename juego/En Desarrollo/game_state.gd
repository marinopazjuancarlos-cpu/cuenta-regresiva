extends Node

enum Final { A, B, C }

const PUNTOS_MINIMOS_FINAL_A = 500
const PUNTOS_MINIMOS_FINAL_B = 210

var puntos_por_final: Dictionary = {Final.A: 0, Final.B: 0, Final.C: 0}


#LLAMAR AL TERMINAR CADA MINIJUEGO DE HOJAS: SUMA UN PUNTO AL FINAL QUE CORRESPONDA
func registrar_puntaje_minijuego(puntos: int) -> void:
	puntos_por_final[_final_por_puntaje(puntos)] += 1


func _final_por_puntaje(puntos: int) -> int:
	if puntos >= PUNTOS_MINIMOS_FINAL_A:
		return Final.A
	elif puntos >= PUNTOS_MINIMOS_FINAL_B:
		return Final.B
	else:
		return Final.C

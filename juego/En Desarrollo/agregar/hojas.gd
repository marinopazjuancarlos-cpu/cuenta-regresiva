extends Node2D

const TIPO_VERDE = "verde"
const TIPO_ROJA = "roja"
const TIPO_PESADA = "pesada"

#LA HOJA PESADA CUESTA MAS "ACEPTARLA" -> REQUIERE VARIOS CLICS
const CLICS_REQUERIDOS = {
	TIPO_VERDE: 1,
	TIPO_ROJA: 1,
	TIPO_PESADA: 3,
}

const COLOR_TIPO = {
	TIPO_VERDE: Color(0.35, 0.85, 0.35),
	TIPO_ROJA: Color(0.85, 0.25, 0.25),
	TIPO_PESADA: Color(0.4, 0.4, 0.45),
}

const SLOTS = ["gas1", "gas2", "gas3"]

const PUNTOS_MINIMOS_FINAL_A = 500
const PUNTOS_MINIMOS_FINAL_B = 210

#VELOCIDAD A LA QUE SUBE UNA HOJA UNA VEZ COMPLETADOS SUS CLICS
const VELOCIDAD_SUBIDA = 6.0

#SEGUNDO (TRANSCURRIDO) EN EL QUE EL DIA 3 SE GLITCHEA:
#TODAS LAS HOJAS VISIBLES SE VUELVEN PESADAS DE GOLPE
const GLITCH_DIA = 3
const GLITCH_TIEMPO = 30.0

#PATRONES DE SPAWN POR DIA (tiempo en segundos desde el inicio del minijuego)
#EL GLITCH DEL DIA 3 SE MANEJA APARTE, VER GLITCH_DIA / GLITCH_TIEMPO
const PATRONES_DIAS = {
	1: {
		"duracion": 30.0,
		"velocidad_caida": 2.0,
		"eventos": [
			{"tiempo": 0.0, "slot": "gas1", "tipo": TIPO_VERDE},
			{"tiempo": 10.0, "slot": "gas3", "tipo": TIPO_VERDE},
			{"tiempo": 20.0, "slot": "gas2", "tipo": TIPO_VERDE},
		],
	},
	2: {
		"duracion": 30.0,
		"velocidad_caida": 3.0,
		"eventos": [
			{"tiempo": 0.0, "slot": "gas1", "tipo": TIPO_VERDE},
			{"tiempo": 10.0, "slot": "gas3", "tipo": TIPO_VERDE},
			{"tiempo": 20.0, "slot": "gas2", "tipo": TIPO_ROJA},
		],
	},
	3: {
		"duracion": 40.0,
		"velocidad_caida": 3.0,
		"eventos": [
			{"tiempo": 0.0, "slot": "gas1", "tipo": TIPO_VERDE},
			{"tiempo": 10.0, "slot": "gas2", "tipo": TIPO_ROJA},
			{"tiempo": 20.0, "slot": "gas3", "tipo": TIPO_PESADA},
		],
	},
}

@export var dia: int = 1

var velocidad_caida: float = 2.0
var puntos: int = 0
var eventos_pendientes: Array = []
var tipos_hoja: Dictionary = {}
var clics_restantes: Dictionary = {}
var en_trampolin: Dictionary = {}
var glitch_activado: bool = false


func _ready() -> void:
	var patron = PATRONES_DIAS.get(dia, PATRONES_DIAS[1])
	velocidad_caida = patron.velocidad_caida
	eventos_pendientes = patron.eventos.duplicate(true)
	eventos_pendientes.sort_custom(func(a, b): return a.tiempo < b.tiempo)

	$Tiempo_restante.wait_time = patron.duracion
	$Tiempo_restante.start()
	$PuntajeTimer.start()

	for slot in SLOTS:
		_tubo_de(get_node(slot)).visible = false


func _tubo_de(gas: Node) -> Button:
	return gas.get_node("tubo" + gas.name.substr(3))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var transcurrido = $Tiempo_restante.wait_time - $Tiempo_restante.time_left
	while eventos_pendientes.size() > 0 and transcurrido >= eventos_pendientes[0].tiempo:
		_spawnear_hoja(eventos_pendientes.pop_front())

	if dia == GLITCH_DIA and not glitch_activado and transcurrido >= GLITCH_TIEMPO:
		_activar_glitch()

	for slot in SLOTS:
		var gas = get_node(slot)
		var tubo = _tubo_de(gas)
		if en_trampolin.get(slot, false):
			#LA HOJA YA FUE ACEPTADA (CLICS COMPLETOS): SUBE DIRECTO
			gas.position.y -= VELOCIDAD_SUBIDA
		elif tubo.visible:
			if gas.position.y < 130:
				#CAIDA DE HOJAS
				gas.position.y += velocidad_caida
			else:
				#LLEGO ABAJO SIN QUE LA ACEPTARAN: SE PIERDE Y DEJA DE CONTAR PUNTOS
				_hoja_caida(slot)

	#CUENTA REGRESIVA
	$Tiempo.text = str(int($Tiempo_restante.time_left))


#DIA 3, SEGUNDO 10 RESTANTE: DANIEL SE IMAGINA LO PEOR Y TODO SE VUELVE PESADO
func _activar_glitch() -> void:
	glitch_activado = true
	for slot in SLOTS:
		if not _tubo_de(get_node(slot)).visible:
			continue
		tipos_hoja[slot] = TIPO_PESADA
		#SI YA IBA SUBIENDO NO SE LE PIDEN CLICS DE MAS, SOLO A LAS QUE SIGUEN CAYENDO
		if not en_trampolin.get(slot, false):
			clics_restantes[slot] = CLICS_REQUERIDOS[TIPO_PESADA]
		_tubo_de(get_node(slot)).modulate = COLOR_TIPO[TIPO_PESADA]
	_sacudir_camara()


func _sacudir_camara() -> void:
	var camara = $Camera2D
	var offset_original = camara.offset
	var tween = create_tween()
	for i in range(6):
		var temblor = Vector2(randf_range(-8, 8), randf_range(-8, 8))
		tween.tween_property(camara, "offset", offset_original + temblor, 0.04)
	tween.tween_property(camara, "offset", offset_original, 0.04)


func _spawnear_hoja(evento: Dictionary) -> void:
	var gas = get_node(evento.slot)
	var tubo = _tubo_de(gas)
	tipos_hoja[evento.slot] = evento.tipo
	clics_restantes[evento.slot] = CLICS_REQUERIDOS[evento.tipo]
	tubo.visible = true
	tubo.modulate = COLOR_TIPO[evento.tipo]


#10 PUNTOS POR CADA HOJA VISIBLE EN PANTALLA, POR CADA SEGUNDO QUE PASA
func _on_puntaje_timer_timeout() -> void:
	for slot in SLOTS:
		if _tubo_de(get_node(slot)).visible:
			puntos += 10


func _on_hoja_presionada(slot: String) -> void:
	if not clics_restantes.has(slot):
		return

	clics_restantes[slot] -= 1
	#LA HOJA PESADA NECESITA VARIOS CLICS ANTES DE SUBIR
	if clics_restantes[slot] > 0:
		return

	en_trampolin[slot] = true


func _on_tubo_1_pressed() -> void:
	_on_hoja_presionada("gas1")


func _on_tubo_2_pressed() -> void:
	_on_hoja_presionada("gas2")


func _on_tubo_3_pressed() -> void:
	_on_hoja_presionada("gas3")


func _on_tiempo_restante_timeout() -> void:
	$Tiempo_restante.stop()
	$PuntajeTimer.stop()
	ControladorJuego.registrar_puntaje_minijuego(puntos, PUNTOS_MINIMOS_FINAL_A, PUNTOS_MINIMOS_FINAL_B)
	#PAUSADOR
	get_tree().paused = true


#LIMPIA EL ESTADO DE UNA HOJA (llegue arriba o se pierda abajo) Y LA OCULTA
func _limpiar_hoja(slot: String) -> void:
	_tubo_de(get_node(slot)).visible = false
	tipos_hoja.erase(slot)
	clics_restantes.erase(slot)
	en_trampolin.erase(slot)


#LA HOJA LLEGO AL FONDO SIN QUE SE COMPLETARAN SUS CLICS: SE PIERDE
func _hoja_caida(slot: String) -> void:
	_limpiar_hoja(slot)


#LA HOJA LLEGO ARRIBA (fue aceptada a tiempo)
func _despawnear_hoja(body: Node2D) -> void:
	if not body.is_in_group("gas"):
		return
	_limpiar_hoja(body.name)


func _on_area_2d_body_entered(body: Node2D) -> void:
	_despawnear_hoja(body)


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	_despawnear_hoja(body)


func _on_area_2d_3_body_entered(body: Node2D) -> void:
	_despawnear_hoja(body)

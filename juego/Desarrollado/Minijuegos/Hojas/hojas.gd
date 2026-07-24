extends Node2D

const TIPO_VERDE = "verde"
const TIPO_ROJA = "roja"
const TIPO_PESADA = "pesada"


const VELOCIDAD_SUBIDA = 6.0
const VELOCIDAD_BAJADA = 2.0

var en_bajada: Dictionary = {}
var en_trampolin: Dictionary = {}

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

const GLITCH_DIA = 3
const GLITCH_TIEMPO = 30.0





const PATRONES_DIAS = {
	1: {
		"duracion": 45.0,
		"velocidad_caida": 1.3,
		"eventos": [
			{"tiempo": 0.0, "slot": "gas1", "tipo": TIPO_VERDE},
			{"tiempo": 4.5, "slot": "gas2", "tipo": TIPO_VERDE},
			{"tiempo": 9.0, "slot": "gas3", "tipo": TIPO_VERDE},
			{"tiempo": 13.5, "slot": "gas1", "tipo": TIPO_VERDE},
			{"tiempo": 18.0, "slot": "gas2", "tipo": TIPO_VERDE},
			{"tiempo": 22.5, "slot": "gas3", "tipo": TIPO_VERDE},
			{"tiempo": 27.0, "slot": "gas1", "tipo": TIPO_VERDE},
			{"tiempo": 31.5, "slot": "gas2", "tipo": TIPO_VERDE},
			{"tiempo": 36.0, "slot": "gas3", "tipo": TIPO_VERDE},
		],
	},
	2: {
		"duracion": 40.0,
		"velocidad_caida": 1.7,
		"eventos": [
			{"tiempo": 0.0, "slot": "gas1", "tipo": TIPO_VERDE},
			{"tiempo": 4.0, "slot": "gas2", "tipo": TIPO_VERDE},
			{"tiempo": 8.0, "slot": "gas3", "tipo": TIPO_VERDE},
			{"tiempo": 12.0, "slot": "gas1", "tipo": TIPO_ROJA},
			{"tiempo": 16.0, "slot": "gas2", "tipo": TIPO_VERDE},
			{"tiempo": 20.0, "slot": "gas3", "tipo": TIPO_ROJA},
			{"tiempo": 24.0, "slot": "gas1", "tipo": TIPO_VERDE},
			{"tiempo": 28.0, "slot": "gas2", "tipo": TIPO_VERDE},
			{"tiempo": 32.0, "slot": "gas3", "tipo": TIPO_ROJA},
			{"tiempo": 36.0, "slot": "gas1", "tipo": TIPO_VERDE},
		],
	},
	3: {
		"duracion": 40.0,
		"velocidad_caida": 2.2,
		"eventos": [
			{"tiempo": 0.0, "slot": "gas1", "tipo": TIPO_VERDE},
			{"tiempo": 3.6, "slot": "gas2", "tipo": TIPO_ROJA},
			{"tiempo": 7.2, "slot": "gas3", "tipo": TIPO_VERDE},
			{"tiempo": 10.8, "slot": "gas1", "tipo": TIPO_ROJA},
			{"tiempo": 14.4, "slot": "gas2", "tipo": TIPO_PESADA},
			{"tiempo": 18.0, "slot": "gas3", "tipo": TIPO_ROJA},
			{"tiempo": 21.6, "slot": "gas1", "tipo": TIPO_VERDE},
			{"tiempo": 25.2, "slot": "gas2", "tipo": TIPO_ROJA},
			{"tiempo": 28.8, "slot": "gas3", "tipo": TIPO_PESADA},
			{"tiempo": 32.4, "slot": "gas1", "tipo": TIPO_VERDE},
			{"tiempo": 36.0, "slot": "gas2", "tipo": TIPO_VERDE},
		],
	},
}

@export var dia: int = 1

var velocidad_caida: float = 2.0
var puntos: int = 0
var eventos_pendientes: Array = []
var tipos_hoja: Dictionary = {}
var clics_restantes: Dictionary = {}
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

# Nueva constante para velocidad horizontal
const VELOCIDAD_HORIZONTAL = 2.5

var direccion_horizontal: Dictionary = {
	"gas1": -1,   # -1 = izquierda, 1 = derecha
	"gas2": -1,
	"gas3": -1,
}


const LIMITE_DERECHA = 480
const LIMITE_IZQUIERDA = -330

func _physics_process(_delta: float) -> void:
	$Label.text =str(puntos)
	var transcurrido = $Tiempo_restante.wait_time - $Tiempo_restante.time_left
	while eventos_pendientes.size() > 0 and transcurrido >= eventos_pendientes[0].tiempo:
		_spawnear_hoja(eventos_pendientes.pop_front())

	if dia == GLITCH_DIA and not glitch_activado and transcurrido >= GLITCH_TIEMPO:
		_activar_glitch()

	for slot in SLOTS:
		var gas = get_node(slot)
		var tubo = _tubo_de(gas)
		if en_trampolin.get(slot, false):
			gas.position.y -= VELOCIDAD_SUBIDA

		elif en_bajada.get(slot, false):
			gas.position.y += VELOCIDAD_BAJADA
			gas.position.x += VELOCIDAD_HORIZONTAL * direccion_horizontal[slot]
			pendulo(gas, slot)

		elif tubo.visible:
			if gas.position.y < 130:
				gas.position.y += velocidad_caida
				gas.position.x += VELOCIDAD_HORIZONTAL * direccion_horizontal[slot]
				pendulo(gas, slot)
			else:
				_hoja_caida(slot)

	$Tiempo.text = str(int($Tiempo_restante.time_left))

				
func pendulo(a, b):
	if a.position.x >= LIMITE_DERECHA:
		direccion_horizontal[b] = -1
	elif a.position.x <= LIMITE_IZQUIERDA:
		direccion_horizontal[b] = 1

func _activar_glitch() -> void:
	glitch_activado = true
	for slot in SLOTS:
		if not _tubo_de(get_node(slot)).visible:
			continue
		tipos_hoja[slot] = TIPO_PESADA
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


func _on_puntaje_timer_timeout() -> void:
	for slot in SLOTS:
		if _tubo_de(get_node(slot)).visible:
			puntos += 10


func _on_hoja_presionada(slot: String) -> void:
	if not clics_restantes.has(slot):
		return
	clics_restantes[slot] -= 1
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
	ControladorJuego.terminar_minijuego(puntos, PUNTOS_MINIMOS_FINAL_A, PUNTOS_MINIMOS_FINAL_B)


func _limpiar_hoja(slot: String) -> void:
	_tubo_de(get_node(slot)).visible = false
	tipos_hoja.erase(slot)
	clics_restantes.erase(slot)
	en_trampolin.erase(slot)
	en_bajada.erase(slot)


func _hoja_caida(slot: String) -> void:
	_limpiar_hoja(slot)


# --- NUEVOS MÉTODOS DE SUBIDA/BAJADA ---
func _en_bajada(slot: String) -> void:
	en_trampolin.erase(slot)
	en_bajada[slot] = true

func _detener_bajada(slot: String) -> void:
	en_bajada.erase(slot)
	_limpiar_hoja(slot)


func _despawnear_hoja(body: Node2D) -> void:
	if not body.is_in_group("gas"):
		return
	_en_bajada(body.name)

func _bajar_hoja(body: Node2D) -> void:
	if not body.is_in_group("gas"):
		return
	_detener_bajada(body.name)



func _on_area_2d_body_entered(body: Node2D) -> void:
	_despawnear_hoja(body)

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	_despawnear_hoja(body)

func _on_area_2d_3_body_entered(body: Node2D) -> void:
	_despawnear_hoja(body)

func _on_area_techo_body_entered(body: Node2D) -> void:
	_bajar_hoja(body)

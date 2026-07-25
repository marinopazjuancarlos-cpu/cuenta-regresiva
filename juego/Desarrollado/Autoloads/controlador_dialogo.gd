extends CanvasLayer

## Autoload: muestra líneas de diálogo con efecto de escritura sobre un panel inferior.
## Uso: await ControladorDialogo.mostrar_dialogo(["Primera línea", "Segunda línea"])

signal linea_avanzada

@export var tiempo_escritura: float = 0.03

@onready var panel: Control = $Panel
@onready var etiqueta: RichTextLabel = $Panel/RichTextLabel

var esta_mostrando: bool = false
var saltar_escritura: bool = false


func _ready() -> void:
	layer = 20
	panel.visible = false
	etiqueta.bbcode_enabled = true


func _unhandled_input(event: InputEvent) -> void:
	if not esta_mostrando:
		return
	if event.is_action_pressed("click"):
		if saltar_escritura:
			linea_avanzada.emit()
		else:
			saltar_escritura = true


## Muestra las líneas una por una. Un clic adelanta la escritura, otro clic pasa a la siguiente línea.
func mostrar_dialogo(lineas: Array) -> void:
	if lineas.is_empty():
		return

	esta_mostrando = true
	panel.visible = true

	for linea in lineas:
		await _mostrar_linea(linea)
		await linea_avanzada

	panel.visible = false
	esta_mostrando = false


func _mostrar_linea(texto: String) -> void:
	etiqueta.text = texto
	etiqueta.visible_characters = 0
	saltar_escritura = false

	var total := etiqueta.get_total_character_count()
	while etiqueta.visible_characters < total:
		if saltar_escritura:
			etiqueta.visible_characters = total
			break
		etiqueta.visible_characters += 1
		await get_tree().create_timer(tiempo_escritura).timeout

	#YA SE TERMINO DE ESCRIBIR: EL SIGUIENTE CLIC AVANZA DE LINEA EN VEZ DE ADELANTAR TEXTO
	saltar_escritura = true

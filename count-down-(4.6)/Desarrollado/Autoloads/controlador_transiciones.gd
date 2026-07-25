extends CanvasLayer


@export var tiempo_escritura_base: float = 0.04
@export var tiempo_espera_coma: float = 0.25
@export var tiempo_espera_punto: float = 0.4
@export var tiempo_espera_elipsis: float = 0.8

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

var esta_escribiendo: bool = false


func ir_a_escena(escena, texto: String = "", pausa_post_texto: float = 1.5) -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var pausa_final: float = 0.0 if texto == "" else pausa_post_texto
	animation_player.play("FadeInOut")
	await animation_player.animation_finished
	
	if texto != "":
		rich_text_label.text = ""
		rich_text_label.visible_characters = true
		await _escribir_texto(texto)
		await get_tree().create_timer(pausa_final).timeout
		rich_text_label.visible_characters = false
		rich_text_label.text = ""
		rich_text_label.visible_characters = 0
	
	if escena is String:
		get_tree().change_scene_to_file(escena)
	elif escena is PackedScene:
		get_tree().change_scene_to_packed(escena)
	else:
		push_error("ControladorTransiciones: Error en la escena recibida debe ser String o PackedScene")
	
	animation_player.play_backwards("FadeInOut")
	await animation_player.animation_finished
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	rich_text_label.visible = false
	rich_text_label.bbcode_enabled = true


func _escribir_texto(texto_a_mostrar: String) -> void:
	rich_text_label.visible = false
	rich_text_label.text = texto_a_mostrar
	rich_text_label.visible_ratio = 0.0
	rich_text_label.visible = true
	esta_escribiendo = true
	
	var total_chars = rich_text_label.get_total_character_count()
	
	while rich_text_label.visible_characters < total_chars and esta_escribiendo:
		rich_text_label.visible_characters += 1
		
		var letra_actual = rich_text_label.get_parsed_text()[rich_text_label.visible_characters - 1]
		var tiempo_espera = tiempo_escritura_base
		
		if letra_actual == ",":
			tiempo_espera = tiempo_espera_coma
		elif letra_actual == ".":
			if _es_elipsis(rich_text_label.visible_characters):
				tiempo_espera = tiempo_espera_elipsis
			else:
				tiempo_espera = tiempo_espera_punto
		elif letra_actual in ["?", "!", ";"]:
			tiempo_espera = tiempo_espera_punto
			
		await get_tree().create_timer(tiempo_espera).timeout
		
	esta_escribiendo = false


func _es_elipsis(index: int) -> bool:
	var parseado = rich_text_label.get_parsed_text()
	if index >= 3:
		if parseado[index - 1] == "." and parseado[index - 2] == "." and parseado[index - 3] == ".":
			return true
	return false

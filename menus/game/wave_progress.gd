extends TextureProgressBar


func _process(delta: float) -> void:
	value = Global.get_wave_progress() * max_value;

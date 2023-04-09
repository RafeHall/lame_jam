extends Button


func _enter_tree() -> void:
	Global.wave_completed.connect(_wave_completed);


func _wave_completed(wave: int) -> void:
	disabled = false;


func _pressed() -> void:
	disabled = true;
	Global.request_wave_start();

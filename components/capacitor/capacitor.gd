extends ComponentScript


var _stage: int = 0;


func input(side: Component.Side, power: int) -> void:
	_stage += 1;


func output(side: Component.Side) -> int:
	if _stage == 3:
		_stage = 0;
		
		return 3;
	else:
		return 0;


func tick(elapsed: int) -> void:
	pass;

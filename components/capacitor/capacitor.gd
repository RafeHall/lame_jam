extends ComponentScript


var _stage: int = 0;


func input(side: Component.Side, power: Component.Power) -> void:
	_stage += 1;


func output(side: Component.Side) -> Component.Power:
	if _stage == 3:
		_stage = 0;
		
		return Component.Power.FULL;
	else:
		return 0;


func tick(elapsed: int) -> void:
	pass;

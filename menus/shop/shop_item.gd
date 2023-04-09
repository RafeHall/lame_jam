extends VBoxContainer


signal clicked(component: Component);


@onready var label: Label = $Label;
@onready var texture_rect: TextureRect = $TextureRect;

var component: Component = null;


func _ready() -> void:
	if component == null:
		queue_free();
	
	label.text = str(component.cost);
	texture_rect.texture = component.icon;


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				clicked.emit(component);

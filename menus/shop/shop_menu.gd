extends Control


@export var shop_item_scene: PackedScene = preload("res://menus/shop/shop_item.tscn");
@export var components: Components = preload("res://components/components.tres");

@onready var item_container: GridContainer = $GridContainer;


func _ready() -> void:
	for component in components.get_as_array():
		if component.buyable:
			var shop_item = shop_item_scene.instantiate();
			shop_item.component = component;
			shop_item.clicked.connect(_item_clicked);
			item_container.add_child(shop_item);


func _item_clicked(component: Component) -> void:
	var spending_money = Global.money;
	if Global.current_component != null:
		spending_money += Global.current_component.cost;
		
	if spending_money >= component.cost:
		if Global.current_component != null:
			Global.money += Global.current_component.cost;
		Global.money -= component.cost;
		Global.current_component = component;

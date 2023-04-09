class_name Enemy
extends Resource

enum EnemyType {
	AIR,
	GROUND,
}

@export var type: EnemyType = EnemyType.GROUND;
@export var enemy_scene: PackedScene = null;
@export var weight: float = 1.0;
@export var speed: float = 50.0;

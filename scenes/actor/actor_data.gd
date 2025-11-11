@abstract
class_name ActorData
extends Node

var actor_name: String
var health: int
var max_health: int
var movement_speed: float
var air_acceleration: float
var ground_acceleration: float


@abstract func _init() -> void;

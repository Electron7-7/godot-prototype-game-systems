class_name PlayerData
extends ActorData

signal fov_changed

var fov: int:
      set(value):
            fov = value
            fov_changed.emit(value)
var spawn_scale := Vector3(0.5, 2.0, 0.5)
var mouse_sensitivity_scale_invert: bool = false
var mouse_sensitivity: float = 1.0
var _mouse_sensitivity_scale: float = 1.0


func _init() -> void:
      actor_name = "GodotPlayer"


func get_mouse_sensitivity_scale() -> float:
      if mouse_sensitivity_scale_invert:
            return _mouse_sensitivity_scale
      else:
            return 1 / _mouse_sensitivity_scale

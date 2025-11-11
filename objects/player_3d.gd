class_name Player3D
extends Node3D

var _look_wish  := Vector2.ZERO
var _move_wish  := Vector3.ZERO
var _mouse_last := Vector2.ZERO
var data := gPlayerData
var velocity := Vector3.ZERO

@onready var head: Node3D = $Head


func _capture_mouse() -> int:
      if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            return 1
      return 0


# TODO: implement this?
func _capture_keyboard() -> int:
      return 1


func _ready() -> void:
      data.fov_changed.connect(_on_fov_changed)


func _input(event: InputEvent) -> void:
      # Taken from my game engine, "Nostalgia"
      _process_movement_controls(Vector2(
            _capture_keyboard() * ((event.is_action_pressed("+right") as int)   - (event.is_action_pressed("+left") as int)),
            _capture_keyboard() * ((event.is_action_pressed("+forward") as int) - (event.is_action_pressed("+backward") as int)),
      ))

      # Semi-taken from my game engine, "Nostalgia"
      _process_camera_controls(_capture_mouse() * (event.screen_relative if event is InputEventMouseMotion else Vector2.ZERO))
      _look()


func _process(_delta: float) -> void:
      _move()


# Semi-taken from my game engine, "Nostalgia"
func _process_camera_controls(mouse_current: Vector2) -> void:
      _look_wish = (_mouse_last + mouse_current) * data.mouse_sensitivity * data.get_mouse_sensitivity_scale()
      _mouse_last = mouse_current


# Taken from my game engine, "Nostalgia"
func _process_movement_controls(direction: Vector2) -> void:
      _move_wish.x += direction.x
      _move_wish.y += direction.y


# Taken from my game engine, "Nostalgia"
func _look() -> void:
      head.rotation_degrees -= Vector3(_look_wish.y, _look_wish.x, 0.0)


# Taken from my game engine, "Nostalgia"
func _move() -> void:
      var l_Front: Vector3 = quaternion * Vector3.FORWARD
      var l_FrontBackVelocity := Vector3(l_Front[0], 0.0, l_Front[2]) * _move_wish[1] * data.movement_speed
      var l_LeftRightVelocity := (quaternion * Vector3.RIGHT) * _move_wish[0] * data.movement_speed
      velocity = l_FrontBackVelocity + l_LeftRightVelocity
      velocity[1] = 0.0 # TODO: add gravity
      global_position += velocity
      _move_wish = Vector3.ZERO


func _on_fov_changed(new_fov: int) -> void:
      $%Camera.fov = new_fov

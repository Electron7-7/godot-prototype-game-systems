class_name GameManager
extends IManager
## The main controller of the game.
##
## Manages all other managers and handles the most important tasks.

enum _ManagerFunction {
      INITIALIZE,
      SHUTDOWN,
}

const _MANAGER_FUNCTION_NAMES: PackedStringArray = [
      "initialize",
      "shutdown",
]

static var _in_game: bool = false
static var _game_paused: bool = false

@onready var _managers: Array[IManager] = [
      gSettingsManager,
      gUIManager,
      gSceneManager,
]


func _ready() -> void:
      initialize()


func capture_cursor() -> void:
      Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func release_cursor() -> void:
      Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func toggle_cursor_capture() -> void:
      if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
      else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func quit_game() -> void:
      if not is_in_game():
            return
      _in_game = false
      _game_paused = false
      gSceneManager.exit_scene()
      gUIManager.solo_menu(gUIManager.Menu.MAIN)
      release_cursor()


func toggle_game_paused() -> void:
      if is_game_paused():
            resume_game()
      else:
            pause_game()


func pause_game() -> bool:
      if not is_in_game() or is_game_paused():
            return false
      _game_paused = true
      gUIManager.solo_menu(gUIManager.Menu.PAUSE)
      release_cursor()
      return true


func resume_game() -> bool:
      if not is_in_game() or not is_game_paused():
            return false
      _game_paused = false
      gUIManager.hide_all_menus()
      capture_cursor()
      return true


## Whether or not a game scene is currently running.
func is_in_game() -> bool:
      return _in_game


## Whether or not the pause menu is open, while [method is_in_game] is [code]true[/code]
func is_game_paused() -> bool:
      return _game_paused


## Implementation of [method IManager.initialize]. Invokes the 'initialize' method on
## every manager in order.
func initialize() -> bool:
      print("GameManager::initialize")
      _invoke_manager_function(_ManagerFunction.INITIALIZE)
      return true


## Implementation of [method IManager.shutdown]. Invokes the 'shutdown' method on
## every manager in reverse order.
func shutdown() -> void:
      print("GameManager::shutdown")
      _invoke_manager_function_reverse(_ManagerFunction.SHUTDOWN)
      get_tree().quit()


func start_game() -> void:
      gSceneManager.start_3d()
      gSceneManager.load_level_3d(load("res://objects/scenes/dev_room.tscn").instantiate())
      capture_cursor()
      _in_game = true
      _game_paused = false


# Calls the given function on every manager, in order.
func _invoke_manager_function(function: _ManagerFunction) -> void:
      for manager in _managers:
            var status = manager.call(_MANAGER_FUNCTION_NAMES[function])
            if function == _ManagerFunction.INITIALIZE and status == false:
                  get_tree().quit(1)


# Calls the given function on every manager, in reverse order.
func _invoke_manager_function_reverse(function: _ManagerFunction) -> void:
      var it: int = _managers.size()
      for i in _managers.size():
            it -= 1
            _managers[it].call(_MANAGER_FUNCTION_NAMES[function])

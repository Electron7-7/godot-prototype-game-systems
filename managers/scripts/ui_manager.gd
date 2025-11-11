class_name UIManager
extends IManager

enum Menu {
      MAIN,
      PAUSE,
      SETTINGS,
}

@onready var main_menu: MainMenu = $MainMenu
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var settings_menu: SettingsMenu = $SettingsMenu
@onready var _menus: Dictionary = {
      Menu.MAIN: main_menu,
      Menu.PAUSE: pause_menu,
      Menu.SETTINGS: settings_menu,
}

var all_menus_closed: bool = true


func _check_all_menus_closed() -> void:
      for _menu in _menus:
            if _menus[_menu].visible:
                  all_menus_closed = false
                  return
      all_menus_closed = true


func show_menu(menu: Menu) -> void:
      _menus[menu].visible = true
      all_menus_closed = false


func hide_menu(menu: Menu) -> void:
      _menus[menu].visible = false
      _check_all_menus_closed()


func hide_all_menus() -> void:
      for _menu in _menus:
            hide_menu(_menu)
      all_menus_closed = true


func solo_menu(menu: Menu) -> void:
      hide_all_menus()
      show_menu(menu)


func toggle_menu(menu: Menu) -> void:
      _menus[menu].visible = not _menus[menu].visible
      if not _menus[menu].visible:
            _check_all_menus_closed()


func initialize() -> bool:
      print("UIManager::initialize")
      for menu in _menus:
            _menus[menu].initialize()
      return true


func shutdown() -> void:
      print("UIManager::shutdown")

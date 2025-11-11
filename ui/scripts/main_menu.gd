class_name MainMenu
extends IMenu


func initialize() -> void:
      print("MainMenu::initialize")


func _ready() -> void:
      $%Settings.connect("pressed", _on_settings_pressed)
      $%Exit.connect("pressed", _on_exit_pressed)
      $%Start.connect("pressed", _on_start_pressed)


func _on_settings_pressed() -> void:
      gUIManager.solo_menu(gUIManager.Menu.SETTINGS)


func _on_exit_pressed() -> void:
      gGameManager.shutdown()


func _on_start_pressed() -> void:
      gGameManager.start_game()
      gUIManager.hide_all_menus()

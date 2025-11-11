class_name PauseMenu
extends IMenu


func initialize() -> void:
      print("PauseMenu::initialize")


func _ready() -> void:
      $%Resume.connect("pressed", _on_resume_pressed)
      $%Settings.connect("pressed", _on_settings_pressed)
      $%Quit.connect("pressed", _on_quit_pressed)


func _input(event: InputEvent) -> void:
      if event.is_action_pressed("pause_menu"):
            if visible:
                  gGameManager.resume_game()
            else:
                  gGameManager.pause_game()


func _on_resume_pressed() -> void:
      gGameManager.resume_game()


func _on_settings_pressed() -> void:
      gUIManager.solo_menu(gUIManager.Menu.SETTINGS)


func _on_quit_pressed() -> void:
      gGameManager.quit_game()

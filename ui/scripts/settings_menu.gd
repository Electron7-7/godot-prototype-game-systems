class_name SettingsMenu
extends IMenu

@onready var _apply_button: Button = $Apply
@onready var _save_button: Button = $Save
@onready var _back_button: Button = $Back
@onready var _discard_button: Button = $Discard


## Implementation of [method IMenu.initialize]. Disables the "apply" and "save"
## buttons, as they get unintentionally enabled during [method SettingsManager.initialize].
func initialize() -> void:
      print("SettingsMenu::initialize")
      _apply_button.disabled = true
      _save_button.disabled  = true


## Re-enables the [member _apply_button] and [member _save_button] when called.
## See [method PersistantSetting.connect_control] for more information.
func setting_changed() -> void:
      _apply_button.disabled   = false
      _save_button.disabled    = false
      _discard_button.disabled = false


func _ready() -> void:
      _save_button.connect("pressed", _on_save_button_pressed)
      _apply_button.connect("pressed", _on_apply_button_pressed)
      _back_button.connect("pressed", _on_back_button_pressed)
      _discard_button.connect("pressed", _on_discard_button_pressed)
      _on_apply_button_pressed()


func _input(event: InputEvent) -> void:
      if event.is_action("ui_cancel") and visible:
            _on_back_button_pressed()


func _on_save_button_pressed() -> void:
      _discard_button.disabled = true
      _save_button.disabled = true
      _on_apply_button_pressed()
      gSettingsManager.save_config()


func _on_apply_button_pressed() -> void:
      _apply_button.disabled = true
      gSettingsManager.save_settings()
      gSettingsManager.apply_settings()


func _on_back_button_pressed() -> void:
      gUIManager.hide_menu(gUIManager.Menu.SETTINGS)
      if not gGameManager.is_in_game():
            gUIManager.show_menu(gUIManager.Menu.MAIN)
      else:
            gUIManager.show_menu(gUIManager.Menu.PAUSE)


func _on_discard_button_pressed() -> void:
      gSettingsManager.load_settings()
      _apply_button.disabled   = true
      _save_button.disabled    = true
      _discard_button.disabled = true

@tool
class_name PersistantSetting
extends HBoxContainer
## Used by certain [Control] Nodes to interface with the SettingManager.
##
## Provides an easy way to create settings that can be loaded and saved.

## A [Label] or [Button] node used to display [member setting_name].
@export_custom(PROPERTY_HINT_NODE_PATH_VALID_TYPES, "Label,BaseButton") var setting_label: NodePath:
      set(value):
            setting_label = value
            if get_node_or_null(setting_label) != null:
                  get_node_or_null(setting_label).text = setting_name
            update_configuration_warnings()

## If you want to interface with [PersistantSetting], you need to assign a valid
## [Control] node to [member setting_control]; valid node types are [BaseButton],
## [TextEdit], [LineEdit], and [Range]. All nodes derived from these types are
## valid, so it's really just the [Container] nodes and non-[Control] nodes that
## aren't valid (alongside a few stragglers).
@export_custom(PROPERTY_HINT_NODE_PATH_VALID_TYPES, "BaseButton,TextEdit,LineEdit,Range") var setting_control: NodePath = "":
      set(value):
            setting_control = value
            setting_default_value = _get_control_value(setting_default_value)

## Which section of the config file this setting belongs to, via [enum SettingsManager.Section].
## [br][br]Defaults to [constant SettingsManager.PLAYER].
@export var setting_section := SettingsManager.Section.PLAYER

## [member setting_name] can [b]not[/b] be empty as it's the key of the key/value
## pair used by [SettingsManager] when interfacing with the [ConfigFile].
@export_placeholder("Setting name") var setting_name: String = &"": set = _set_setting_name

## The setting's current value. This is used by [SettingsManager] when saving
## data to the [ConfigFile]. When this variable is changed, [method SettingsMenu.settings_changed]
## gets called, which re-enables the "apply" and "save" buttons. Changing this
## variable will also attempt to update the [Control] node at [member setting_control]
## to the same value (if [member setting_control] points to a valid node).
@export_storage var setting_value: Variant: set = _set_setting_value

## The default value if no value for this setting was saved in the [ConfigFile].
## During [method PersistantSetting._ready], this is set to the value of
## [member setting_control] (see [method set_to_control_value] for more details).
## This allows for default values to be easily set in the Editor.
@export_storage var setting_default_value: Variant

# Stops infinite loops from being caused by `_on_control_changed`
var _ok_to_update_control_value: bool = true


func _set_setting_value(value: Variant) -> void:
      setting_value = value
      if gUIManager.settings_menu != null:
            gUIManager.settings_menu.setting_changed()
      if _ok_to_update_control_value:
            _set_control_value(value)


func _set_setting_name(value: String) -> void:
      setting_name = value
      name = value
      if get_node_or_null(setting_label) != null:
            get_node_or_null(setting_label).text = value
      update_configuration_warnings()


## A quick way to both check if [member setting_name] is empty [i]and[/i] push
## an error to the debugger if [param do_push_error] is [code]true[/code]. See
## [member setting_name] for more details.
func is_invalid(do_push_error: bool = true) -> bool:
      if setting_name.is_empty():
            if do_push_error:
                  push_error("'setting_name' is empty")
            return true
      return false


## If [member setting_control] points to a valid node (i.e isn't [code]null[/code]),
## then one of its signals is connected to a function that updates [member setting_value]
## to that [Control] node's new value. The connected signal depends on the node's
## type and is either [signal BaseButton.toggled], [signal OptionButton.item_selected],
## [signal TextEdit.text_changed], [signal LineEdit.text_changed], or
## [signal Range.changed].
func connect_control() -> void:
      var l_Control = get_node_or_null(setting_control)
      if setting_control.is_empty():
            return
      elif l_Control == null:
            push_warning("PersistantSetting '%s' has an invalid 'setting_control' NodePath: %s" % [name, setting_control])
            return
      elif l_Control.is_class("BaseButton"):
            if l_Control.is_class("OptionButton"):
                  l_Control.connect("item_selected", _on_control_changed)
            else:
                  l_Control.connect("toggled", _on_control_changed)
      elif l_Control.is_class("TextEdit") or l_Control.is_class("LineEdit"):
            l_Control.connect("text_changed", _on_control_changed)
      elif l_Control.is_class("Range"):
            l_Control.connect("value_changed", _on_control_changed)


func _get_control_value(return_if_failed) -> Variant:
      var l_Control = get_node_or_null(setting_control)
      if l_Control == null:
            return return_if_failed
      elif l_Control.is_class("BaseButton"):
            if l_Control.is_class("OptionButton"):
                  return l_Control.get("selected")
            return l_Control.get("button_pressed")
      elif l_Control.is_class("TextEdit") or l_Control.is_class("LineEdit"):
            return l_Control.get("text")
      elif l_Control.is_class("Range"):
            return l_Control.get("value")
      return return_if_failed


func _set_control_value(value: Variant) -> void:
      var l_Control = get_node_or_null(setting_control)
      if l_Control == null:
            return
      elif l_Control.is_class("BaseButton"):
            if l_Control.is_class("OptionButton"):
                  l_Control.set("selected", value)
            else:
                  l_Control.set("button_pressed", value)
      elif l_Control.is_class("TextEdit") or l_Control.is_class("LineEdit"):
            l_Control.set("text", value)
      elif l_Control.is_class("Range"):
            l_Control.set("value", value)


func _get_configuration_warnings() -> PackedStringArray:
      var warnings: PackedStringArray = []
      if setting_name.is_empty():
            warnings.append("'setting_name' cannot be empty.")
      return warnings


func _init() -> void:
      if not gSettingsManager.all_settings.has(self):
            gSettingsManager.all_settings.push_back(self)


func _ready() -> void:
      print("PersistantSetting::_ready - %s" % name)
      setting_default_value = _get_control_value(setting_default_value)
      connect_control()


func _on_control_changed(value) -> void:
      _ok_to_update_control_value = false
      if get_node_or_null(setting_control).is_class("OptionButton"):
            setting_value = get_node_or_null(setting_control).get_item_id(value)
      else:
            setting_value = value
      _ok_to_update_control_value = true

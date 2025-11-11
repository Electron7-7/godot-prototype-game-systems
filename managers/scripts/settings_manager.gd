class_name SettingsManager
extends IManager
## The manager for everything related to [code]user://Settings.cfg[/code]

## Identifier for the different sections in the config file.
enum Section {
      PLAYER,
      INPUT,
      DISPLAY,
      GRAPHICS,
}

## A [Dictionary] mapping [enum Section] values to their relevant [String] names.
const SECTIONS: Dictionary = {
      Section.PLAYER   : "Player",
      Section.INPUT    : "Input",
      Section.DISPLAY  : "Display",
      Section.GRAPHICS : "Graphics",
}

## File path for the settings config file.
const FILE_PATH: String = "user://Settings.cfg"

var _config := ConfigFile.new()

## An [Array] that contains every [PersistantSetting] node. During
## [method PersistantSetting._ready], each [PersistantSetting] node adds itself
## to the [Array] if it doesn't already contain it.
var all_settings: Array[PersistantSetting] = []


func _clear_config() -> void:
      if FileAccess.file_exists(FILE_PATH):
            var l_File := FileAccess.open(FILE_PATH, FileAccess.WRITE)
            l_File.store_string("")
            l_File.close()


## Calls [method set_value] with the section, name, and value of every setting in
## [member all_settings].
func save_settings() -> void:
      for setting in all_settings:
            set_value(
                  setting.setting_section,
                  setting.setting_name,
                  setting.setting_value)


## Applies the current settings. Call this [i]after[/i] [method save_settings].
## [br][br]TODO: Replace the [String] match with an enum match specific to the setting.
## Perhaps even let the user set each [PersistantSetting] to a specific setting via
## this enum; most likely this enum will only be used for certain settings, like
## Engine settings (e.g: fullscreen, fps, etc).
func apply_settings() -> void:
      for setting in all_settings:
            match setting.setting_name:
                  "Window Mode":
                        DisplayServer.window_set_mode(setting.setting_value)
                  "FOV":
                        gPlayerData.fov = setting.setting_value
                  "Mouse Sensitivity":
                        gPlayerData.mouse_sensitivity = setting.setting_value
                  "Mouse Sensitivity Scale":
                        gPlayerData._mouse_sensitivity_scale = setting.setting_value
                  "Mouse Sensitivity Scaling Inverted":
                        gPlayerData.mouse_sensitivity_scale_invert = setting.setting_value


## Abstraction of [method ConfigFile.save], passing [constant Settings.FILE_PATH] as
## [param path]. Returns [code]true[/code] or [code]false[/code] depending on
## whether or not the value of [method ConfigFile.save] is [constant OK] or not.
func save_config() -> bool:
      if _config.save(FILE_PATH) != OK:
            push_error("_config.save(%s) failed" % FILE_PATH)
            return false
      return true


## Abstraction of [method ConfigFile.load], passing [constant Settings.FILE_PATH] as
## [param path]. Returns [code]true[/code] or [code]false[/code] depending on
## whether or not the value of [method ConfigFile.load] is [constant OK] or not.
func load_config() -> bool:
      if _config.load(FILE_PATH) != OK:
            push_error("_config.load(%s) failed" % FILE_PATH)
            return false
      return true


## Updates every setting in [member all_settings] with the value
## of [method get_value], using [member PersistantSetting.setting_default_value]
## as the [param default_value].
func load_settings() -> void:
      for setting in all_settings:
            setting.setting_value = get_value(
                  setting.setting_section,
                  setting.setting_name,
                  setting.setting_default_value)


## Abstraction of [method ConfigFile.get_value] using [enum Section].
func get_value(section: Section, key: String, default_value: Variant) -> Variant:
      return _config.get_value(SECTIONS[section], key, default_value)


## Abstraction of [method ConfigFile.set_value] using [enum Section].
func set_value(section: Section, key: String, value: Variant) -> void:
      _config.set_value(SECTIONS[section], key, value)


## Abstraction of [method ConfigFile.erase_section_key] using [enum Section],
## and returning either [code]true[/code] or [code]false[/code] if the given
## [param section] and [param key] were erased or not (i.e: they existed).
func erase_section_key(section: Section, key: String) -> bool:
      var l_Status: bool = has(key, section)
      _config.erase_section_key(SECTIONS[section], key)
      return l_Status


## Calls [method ConfigFile.get_section_keys] and [method PackedStringArray.has]
## to quickly determine whether or not the given [param key] exists in the given
## section. To find out whether or not a given key exists in [i]any[/i] of the
## config file sections, use [method has_slow] (but be warned, it's much slower...
## hence the name).
func has(key: String, in_section: Section) -> bool:
      return _config.get_section_keys(SECTIONS[in_section]).has(key)


## Recursively checks each section of the loaded [ConfigFile] for the given [param key].
## Returns [code]true[/code] if found and [code]false[/code] if not. This function
## is slower than [method has], but lets you be more thorough when checking for keys.
func has_slow(key: String) -> bool:
      for section in _config.get_sections():
            if _config.get_section_keys(section).has(key):
                  return true
      return false


## Implementation of [method IManager.initialize] for [SettingsManager].[br][br]
## Attempts to load the config file, trim any missing settings, save the config
## file, and update all [PersistantSetting] objects with their saved values.
func initialize() -> bool:
      if not load_config():
            push_error("load_config failed")
            return false
      _trim_missing_settings()
      if not save_config():
            push_error("save_config failed")
            return false
      load_settings()
      print("SettingsManager::initialize")
      return true


func shutdown() -> void:
      print("SettingsManager::shutdown")


# Uses all_settings to create an array containing the names of
# every PersistantSetting object. This array is then used in a terribly-nested
# series of for-loops to erase any entries from the config file that don't have
# an associated PersistantSetting. Any entry that gets removed will also print a
# message to the console.
func _trim_missing_settings() -> void:
      var l_AllKeys: PackedStringArray = []
      for setting in all_settings:
            if not setting.is_invalid():
                  l_AllKeys.push_back(setting.setting_name)
      for section in _config.get_sections():
            for key in _config.get_section_keys(section):
                  if not l_AllKeys.has(key):
                        print("SettingsManager::_trim_missing_settings - removing setting '%s' from section '%s" % [key, section])
                        _config.erase_section_key(section, key)

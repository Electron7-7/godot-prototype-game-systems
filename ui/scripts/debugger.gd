class_name Debugger
extends Node2D


var _variables: Dictionary[String, Variant] = {}
var _variables_nodes: Dictionary[String, Label]
var _console_mouse_down: bool = false
var _console_mouse_offset := Vector2.ZERO


func assign(variable_name: String, variable_value: Variant) -> void:
      _variables[variable_name] = variable_value
      if _variables_nodes.has(variable_name):
            return
      _variables_nodes[variable_name] = Label.new()
      $%VariablesList.add_child(_variables_nodes[variable_name])
      _variables_nodes[variable_name].text = "%s" % variable_value


func erase(variable_name: String) -> Error:
      if _variables_nodes.has(variable_name):
            _variables_nodes[variable_name].queue_free()
            _variables_nodes.erase(variable_name)
      if not _variables.erase(variable_name):
            return ERR_DOES_NOT_EXIST
      return OK


func clear() -> void:
      if OS.has_feature("debug"):
            var l_Vars: String = ""
            for key in _variables:
                  l_Vars += "\t%s: %s,\n" % [key, _variables[key]]
            print("Contents of '_variables' before 'clear':\n%s" % l_Vars)
      _variables.clear()
      for node in _variables_nodes:
            _variables_nodes[node].queue_free()
      _variables_nodes.clear()


func _update_variables() -> void:
      if OS.has_feature("debug"):
            for node_name in _variables_nodes:
                  _variables_nodes[node_name].text = "%s: %s" % [node_name, _variables[node_name]]


func show_info() -> void:
      if OS.has_feature("debug"):
            $%DebugInfo.visible = true


func hide_info() -> void:
      if OS.has_feature("debug"):
            $%DebugInfo.visible = false


func toggle_info() -> void:
      if OS.has_feature("debug"):
            $%DebugInfo.visible = not $%DebugInfo.visible


func show_console() -> void:
      if OS.has_feature("debug"):
            $%DebugConsole.visible = true


func hide_console() -> void:
      if OS.has_feature("debug"):
            $%DebugConsole.visible = false


func toggle_console() -> void:
      if OS.has_feature("debug"):
            $%DebugConsole.visible = not $%DebugConsole.visible


func _process(_delta: float) -> void:
      if _console_mouse_down:
            $%DebugConsole.position = get_global_mouse_position() - _console_mouse_offset
      _update_variables()


func _input(event: InputEvent) -> void:
      if event.is_action_pressed("debug_info"):
            toggle_info()
      elif event.is_action_pressed("debug_console"):
            toggle_console()


func _on_debug_info_close_requested() -> void:
      hide_info()


func _on_console_gui_input(event: InputEvent) -> void:
      if event is InputEventMouseButton:
            if event.button_index == MOUSE_BUTTON_LEFT:
                  _console_mouse_down = event.pressed
                  _console_mouse_offset = $%DebugConsole.get_local_mouse_position()

@tool
class_name ConsoleLine
extends LineEdit

enum Prefix {
      CARET,
      DOLLAR,
      HASH,
      COLON,
}

const _prefixes: PackedStringArray = [
      "> ",
      "$ ",
      "# ",
      ": ",
]

@export_custom(PROPERTY_HINT_NODE_PATH_VALID_TYPES, "Container") var command_history_container: NodePath = ""
@export var use_prefix := true:
      set(value):
            use_prefix = value
            _update_prefix()
            _on_text_changed()
@export var prefix_type := Prefix.CARET:
      set(value):
            prefix_type = value
            _update_prefix()
            _on_text_changed()

var _prefix_text := _prefixes[prefix_type]


func get_command() -> String:
      if use_prefix:
            return text.substr(1)
      return text


func _init() -> void:
      text_changed.connect(_on_text_changed)
      text_submitted.connect(_on_text_submitted)
      _update_prefix()
      _on_text_changed()


func _process(_delta: float) -> void:
      _set_caret()


func _set_caret() -> void:
      if caret_column < 2:
            caret_column = 2


func _on_text_changed(_text: String = "") -> void:
      if not use_prefix:
            if text.begins_with(_prefix_text):
                  text.erase(0, 2)
            return
      elif not text.begins_with(_prefix_text):
            if text.begins_with(_prefix_text[0]):
                  text = text.insert(1, " ")
                  _set_caret()
                  return
            text = text.insert(0, _prefix_text)
      _set_caret()


func _on_text_submitted(_text: String = "") -> void:
      if get_node_or_null(command_history_container) == null:
            return
      var l_History := get_node(command_history_container)
      l_History.add_child(SingleCommand.new(get_command()), false, Node.INTERNAL_MODE_BACK)
      text = ""
      _on_text_changed()


func _update_prefix() -> void:
      _prefix_text = _prefixes[prefix_type]

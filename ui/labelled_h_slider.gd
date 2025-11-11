@tool
class_name HSliderLabelled
extends HSlider
## An [HSlider] control with an added [LineEdit] child.


@export_storage var _label := LineEdit.new()
@export_storage var _label_added: float = false

## A nice way to select the display type for [member HSlider.value]. This will
## only change how the value is displayed via the [LineEdit] child.
@export_enum("Float:3", "Integer:2") var value_type: int = TYPE_FLOAT:
      set(new_value):
            value_type = new_value
            _on_value_changed(new_value)

@export var label_is_editable: bool = true:
      set(new_value):
            label_is_editable = new_value
            _label.editable = label_is_editable


func _get_value():
      if value_type == TYPE_FLOAT:
            return value
      return (value as int)


func _ready() -> void:
      size_flags_vertical = Control.SIZE_SHRINK_CENTER
      if get_child_count(true) > 0:
            return
      add_child(_label, true, Node.INTERNAL_MODE_FRONT)
      value_changed.connect(_on_value_changed)
      resized.connect(_on_minimum_size_changed)
      _on_value_changed(value)
      if custom_minimum_size.x < 16:
            custom_minimum_size.x = 16
      custom_minimum_size.y = _label.size.y
      _label.position.y = position.y
      _label.connect("text_submitted", _on_label_text_submitted)
      _label.editable = label_is_editable
      _label_added = true


func _on_value_changed(new_value: float) -> void:
      if value_type == TYPE_FLOAT:
            _label.text = str(new_value)
      else:
            _label.text = str(new_value as int)


func _on_minimum_size_changed() -> void:
      _label.position.x = get_combined_minimum_size().x + 5


func _on_label_text_submitted(new_text: String) -> void:
      if not new_text.is_valid_float():
            _label.text = str(get_value())
            push_warning("label text must be a valid %s only" % type_string(value_type))
            return
      set_value_no_signal(new_text.to_float())

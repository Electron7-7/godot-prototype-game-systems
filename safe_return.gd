class_name SafeReturn
extends RefCounted
## A custom type for returning some [Variant] along with some [enum Error] status.
##
## Useful for when a function needs to return a value [i]but[/i] could also fail.
## With [SafeReturn], you can check the status of a function call the same way
## every time.

## The returned data of a function.
var value: Variant = null

## The status of a function.
var status: Error  = FAILED


func _init(value_: Variant, status_: Error = OK) -> void:
      value  = value_
      status = status_


## Returns the result of checking if [member status] is not [constant OK]. If
## [param null_value_is_invalid] is [code]true[/code], then [member value] begin
## [code]null[/code] will also cause this function to return [code]true[/code].
func invalid(null_value_is_invalid: bool = true) -> bool:
      return status != OK or (null_value_is_invalid and value == null)

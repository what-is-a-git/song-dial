class_name Option extends RefCounted


var value = null
var is_some: bool = false


func unwrap() -> Variant:
	assert(is_some, 'Failed to confirm that the current option was some.')
	return value

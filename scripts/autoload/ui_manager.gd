extends Node

func format_number(value: int) -> String:
	if value >= 1000000:
		return "%.1fM" % (value / 1000000.0)
	if value >= 1000:
		return "%.1fK" % (value / 1000.0)
	return str(value)

func format_time(seconds: float) -> String:
	var total: int = max(0, int(ceil(seconds)))
	return "%02d:%02d" % [total / 60, total % 60]

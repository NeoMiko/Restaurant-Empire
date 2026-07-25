class_name EmployeeData
extends Resource

@export var id: StringName
@export var display_name: String
@export_enum("Chef", "Waiter", "Cashier", "Cleaner", "Manager") var role: String
@export_enum("Common", "Rare", "Epic", "Legendary", "Mythic") var rarity: String
@export var speed := 1.0
@export var capacity := 1
@export var passive_skill: String

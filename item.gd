class_name Item

var itemset: String
var base_value: int
var rarity: int
var slipperiness: float
var model: String

func _init(itemset: String, base_value: int, rarity: int, slipperiness: float, model: String) -> void:
    self.itemset = itemset
    self.base_value = base_value
    self.rarity = rarity
    self.slipperiness = slipperiness
    self.model = model
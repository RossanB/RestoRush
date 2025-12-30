extends RefCounted
class_name Recipes

# Recipe definitions for each food
static var RECIPES = {
	ItemTypes.ItemType.TACO: {
		"steps": [
			{"action": "get", "item": ItemTypes.ItemType.FLOUR, "source": "cabinet"},
			{"action": "get", "item": ItemTypes.ItemType.WATER, "source": "sink"},
			{"action": "mix", "items": [ItemTypes.ItemType.FLOUR, ItemTypes.ItemType.WATER], "result": ItemTypes.ItemType.DOUGH, "station": "cutting_board"},
			{"action": "get", "item": ItemTypes.ItemType.LETTUCE, "source": "cabinet"},
			{"action": "chop", "item": ItemTypes.ItemType.LETTUCE, "result": ItemTypes.ItemType.CHOPPED_LETTUCE, "station": "cutting_board"},
			{"action": "get", "item": ItemTypes.ItemType.MEAT, "source": "fridge"},
			{"action": "chop", "item": ItemTypes.ItemType.MEAT, "result": ItemTypes.ItemType.PEPPERONI, "station": "cutting_board"},
			{"action": "get", "item": ItemTypes.ItemType.TOMATO, "source": "cabinet"},
			{"action": "chop", "item": ItemTypes.ItemType.TOMATO, "result": ItemTypes.ItemType.CHOPPED_TOMATO, "station": "cutting_board"},
			{"action": "cook", "items": [ItemTypes.ItemType.DOUGH, ItemTypes.ItemType.CHOPPED_LETTUCE, ItemTypes.ItemType.PEPPERONI, ItemTypes.ItemType.CHOPPED_TOMATO], "result": ItemTypes.ItemType.TACO, "station": "oven"}
		]
	},
	ItemTypes.ItemType.FRIES: {
		"steps": [
			{"action": "get", "item": ItemTypes.ItemType.POTATO, "source": "cabinet"},
			{"action": "chop", "item": ItemTypes.ItemType.POTATO, "result": ItemTypes.ItemType.UNCUT_FRIES, "station": "cutting_board"},
			{"action": "cook", "item": ItemTypes.ItemType.UNCUT_FRIES, "result": ItemTypes.ItemType.FRIES, "station": "stove"}
		]
	},
	ItemTypes.ItemType.PIZZA: {
		"steps": [
			{"action": "get", "item": ItemTypes.ItemType.FLOUR, "source": "cabinet"},
			{"action": "get", "item": ItemTypes.ItemType.WATER, "source": "sink"},
			{"action": "mix", "items": [ItemTypes.ItemType.FLOUR, ItemTypes.ItemType.WATER], "result": ItemTypes.ItemType.DOUGH, "station": "cutting_board"},
			{"action": "get", "item": ItemTypes.ItemType.MEAT, "source": "fridge"},
			{"action": "chop", "item": ItemTypes.ItemType.MEAT, "result": ItemTypes.ItemType.PEPPERONI, "station": "cutting_board"},
			{"action": "cook", "items": [ItemTypes.ItemType.DOUGH, ItemTypes.ItemType.PEPPERONI], "result": ItemTypes.ItemType.PIZZA, "station": "oven"}
		]
	},
	ItemTypes.ItemType.SUNNY_SIDEUP_EGG: {
		"steps": [
			{"action": "get", "item": ItemTypes.ItemType.EGG, "source": "fridge"},
			{"action": "cook", "item": ItemTypes.ItemType.EGG, "result": ItemTypes.ItemType.SUNNY_SIDEUP_EGG, "station": "stove"}
		]
	},
	ItemTypes.ItemType.ICECREAM: {
		"steps": [
			{"action": "get", "item": ItemTypes.ItemType.MILK, "source": "fridge"},
			{"action": "mix", "items": [ItemTypes.ItemType.MILK], "result": ItemTypes.ItemType.ICECREAM, "station": "mixer"}
		]
	},
	ItemTypes.ItemType.COLA: {
		"steps": [
			{"action": "get", "item": ItemTypes.ItemType.COLA, "source": "fridge"}
		]
	},
	ItemTypes.ItemType.FRUIT: {
		"steps": [
			{"action": "get", "item": ItemTypes.ItemType.FRUIT, "source": "fridge"}
		]
	},
	ItemTypes.ItemType.DONUTS: {
		"steps": [
			{"action": "get", "item": ItemTypes.ItemType.FLOUR, "source": "cabinet"},
			{"action": "get", "item": ItemTypes.ItemType.WATER, "source": "sink"},
			{"action": "mix", "items": [ItemTypes.ItemType.FLOUR, ItemTypes.ItemType.WATER], "result": ItemTypes.ItemType.DOUGH, "station": "cutting_board"},
			{"action": "get", "item": ItemTypes.ItemType.GLAZE, "source": "fridge"},
			{"action": "cook", "items": [ItemTypes.ItemType.DOUGH, ItemTypes.ItemType.GLAZE], "result": ItemTypes.ItemType.DONUTS, "station": "oven"}
		]
	},
	# Standalone processing: Meat -> Pepperoni
	ItemTypes.ItemType.PEPPERONI: {
		"steps": [
			{"action": "get", "item": ItemTypes.ItemType.MEAT, "source": "fridge"},
			{"action": "chop", "item": ItemTypes.ItemType.MEAT, "result": ItemTypes.ItemType.PEPPERONI, "station": "cutting_board"}
		]
	}
}

# Items available in fridge
static var FRIDGE_ITEMS = [
	ItemTypes.ItemType.MEAT,
	ItemTypes.ItemType.EGG,
	ItemTypes.ItemType.MILK,
	ItemTypes.ItemType.COLA,
	ItemTypes.ItemType.FRUIT,
	ItemTypes.ItemType.GLAZE
]

# Items available in cabinet
static var CABINET_ITEMS = [
	ItemTypes.ItemType.FLOUR,
	ItemTypes.ItemType.LETTUCE,
	ItemTypes.ItemType.TOMATO,
	ItemTypes.ItemType.POTATO
]




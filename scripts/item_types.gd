extends RefCounted
class_name ItemTypes

# Item type constants (using integers)
enum ItemType {
	# Base ingredients
	FLOUR = 0,
	WATER = 1,
	DOUGH = 2,
	LETTUCE = 3,
	TOMATO = 4,
	MEAT = 5,
	PEPPERONI = 6,
	POTATO = 7,
	EGG = 8,
	MILK = 9,
	COLA = 10,
	FRUIT = 11,
	GLAZE = 12,
	
	# Processed ingredients
	CHOPPED_LETTUCE = 13,
	CHOPPED_TOMATO = 14,
	CHOPPED_MEAT = 15,
	CHOPPED_PEPPERONI = 16,
	UNCUT_FRIES = 17,
	
	# Cooked/assembled foods
	TACO = 18,
	PIZZA = 19,
	FRIES = 20,
	SUNNY_SIDEUP_EGG = 21,
	ICECREAM = 22,
	DONUTS = 23
}

# Item names
static var ITEM_NAMES = {
	ItemType.FLOUR: "Flour",
	ItemType.WATER: "Water",
	ItemType.DOUGH: "Dough",
	ItemType.LETTUCE: "Lettuce",
	ItemType.TOMATO: "Tomato",
	ItemType.MEAT: "Meat",
	ItemType.PEPPERONI: "Pepperoni",
	ItemType.POTATO: "Potato",
	ItemType.EGG: "Egg",
	ItemType.MILK: "Milk",
	ItemType.COLA: "Cola",
	ItemType.FRUIT: "Fruit",
	ItemType.GLAZE: "Glaze",
	ItemType.CHOPPED_LETTUCE: "Chopped Lettuce",
	ItemType.CHOPPED_TOMATO: "Chopped Tomato",
	ItemType.CHOPPED_MEAT: "Chopped Meat",
	ItemType.CHOPPED_PEPPERONI: "Chopped Pepperoni",
	ItemType.UNCUT_FRIES: "Uncut Fries",
	ItemType.TACO: "Taco",
	ItemType.PIZZA: "Pizza",
	ItemType.FRIES: "Fries",
	ItemType.SUNNY_SIDEUP_EGG: "Sunny Sideup Egg",
	ItemType.ICECREAM: "Icecream",
	ItemType.DONUTS: "Donuts"
}

# Item texture paths
static var ITEM_TEXTURES = {
	ItemType.FLOUR: "res://assets/environment/ingredients/flour.png",
	ItemType.WATER: "res://assets/environment/ingredients/water.png",
	ItemType.DOUGH: "res://assets/environment/ingredients/dough.png",
	ItemType.LETTUCE: "res://assets/environment/ingredients/lettuce.png",
	ItemType.TOMATO: "res://assets/environment/ingredients/tomato.png",
	ItemType.MEAT: "res://assets/environment/ingredients/meat.png",
	ItemType.PEPPERONI: "res://assets/environment/ingredients/peperonni.png",  # Note: filename has double 'n'
	ItemType.POTATO: "res://assets/environment/ingredients/potato.png",
	ItemType.EGG: "res://assets/environment/ingredients/egg.png",
	ItemType.MILK: "res://assets/environment/ingredients/milk.png",
	ItemType.COLA: "res://assets/environment/ingredients/cola.png",
	ItemType.FRUIT: "res://assets/environment/ingredients/orange_juice.png",  # Using orange_juice as fruit
	ItemType.GLAZE: "res://assets/environment/ingredients/glaze.png",
	ItemType.CHOPPED_LETTUCE: "res://assets/environment/ingredients/chopped_lettuce.png",
	ItemType.CHOPPED_TOMATO: "res://assets/environment/ingredients/chopped_tomato.png",
	ItemType.CHOPPED_MEAT: "res://assets/environment/ingredients/chopped_meat.png",
	ItemType.CHOPPED_PEPPERONI: "res://assets/environment/ingredients/chopped_pepperoni.png",
	ItemType.UNCUT_FRIES: "res://assets/environment/ingredients/uncooked_fries.png",
	ItemType.TACO: "res://assets/environment/ingredients/taco.png",
	ItemType.PIZZA: "res://assets/environment/ingredients/pizza.png",
	ItemType.FRIES: "res://assets/environment/ingredients/fries.png",
	ItemType.SUNNY_SIDEUP_EGG: "res://assets/environment/ingredients/fried_egg.png",
	ItemType.ICECREAM: "res://assets/environment/ingredients/icecream.png",
	ItemType.DONUTS: "res://assets/environment/ingredients/donut.png"  # Note: filename is singular
}

static func get_item_name(item_type: int) -> String:
	if item_type in ITEM_NAMES:
		return ITEM_NAMES[item_type]
	return "Unknown Item"

static func get_item_texture_path(item_type: int) -> String:
	if item_type in ITEM_TEXTURES:
		return ITEM_TEXTURES[item_type]
	return ""


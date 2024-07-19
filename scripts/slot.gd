extends Panel

@onready var background = $background
@onready var item_sprite = $CenterContainer/Panel/item
@onready var amount_label = $CenterContainer/Panel/Label

func update(slot: InventorySlot):
	if !slot.item:
		background.frame = 0
		item_sprite.visible = false
		amount_label.visible = false
	else:
		background.frame = 0
		item_sprite.visible = true
		item_sprite.texture = slot.item.texture
		amount_label.visible = true
		amount_label.text = str(slot.amount)

extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("player died")
	body.get_node("CollisionShape2D").queue_free()
	get_tree().reload_current_scene()
	

extends ProgressBar
class_name BattleStatusBar

func updateStatusBar(friendlyPartyStats: float, enemyPartyStats: float) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "max_value", friendlyPartyStats + enemyPartyStats, 0.5)
	tween.tween_property(self, "value", friendlyPartyStats, 0.5)

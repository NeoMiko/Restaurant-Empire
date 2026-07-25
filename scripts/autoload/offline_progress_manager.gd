extends Node

func apply_elapsed(last_save_unix: int) -> Dictionary:
	var now := TimeManager.unix_now()
	var raw: int = max(0, now - max(0, last_save_unix))
	var cap := int(DataManager.balance.economy.get("offline_max_seconds", 28800))
	var elapsed: int = min(raw, cap)
	for plot in GameManager.state.get("garden", []):
		if str(plot.get("status", "")) == "GROWING":
			plot.remaining = max(0.0, float(plot.get("remaining", 0.0)) - float(elapsed))
			if float(plot.remaining) <= 0.0:
				plot.status = "READY"
	var per_minute := float(DataManager.balance.economy.get("offline_coins_per_minute", 8.0))
	var xp_rate := float(DataManager.balance.economy.get("offline_xp_per_minute", 0.5))
	var prestige_bonus := EconomyManager.balance("prestige_tokens") * float(DataManager.balance.get("prestige", {}).get("income_bonus_per_token", 0.05))
	var multiplier := 1.0 + prestige_bonus + GameManager.bonus("offline_earnings") + GameManager.blessing("income")
	var reward := {"seconds":elapsed,"coins":int(floor(elapsed / 60.0 * per_minute * multiplier)),"xp":int(floor(elapsed / 60.0 * xp_rate))}
	GameManager.state.offline_pending = reward
	return reward

func claim_pending() -> Dictionary:
	var reward: Dictionary = GameManager.state.get("offline_pending", {"seconds":0,"coins":0,"xp":0}).duplicate(true)
	if int(reward.get("coins", 0)) > 0:
		EconomyManager.add("coins", int(reward.coins), "offline reward")
		EconomyManager.add_player_xp(int(reward.get("xp", 0)))
	GameManager.state.offline_pending = {"seconds":0,"coins":0,"xp":0}
	SaveManager.queue_save()
	return reward

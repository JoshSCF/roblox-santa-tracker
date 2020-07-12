game.Players.PlayerAdded:Connect(function(player)
	if game:GetService("GamePassService"):PlayerHasPass(player, 1219605577) then
		game.ReplicatedStorage:WaitForChild("replacesanta"):FireClient(player)
	end
	game:GetService("BadgeService"):AwardBadge(game.Players:GetUserIdFromNameAsync(player.Name), 1228054030)
end)

game.ReplicatedStorage:WaitForChild("awardpoints").OnServerEvent:Connect(function(plr, points)
	game:GetService("PointsService"):AwardPoints(game.Players:GetUserIdFromNameAsync(plr.Name), points)
end)
---[[
game.ReplicatedStorage:WaitForChild("checkscratch").OnServerEvent:Connect(function(player)
	if game:GetService("GamePassService"):PlayerHasPass(player, 1235741280) then
		game.ReplicatedStorage:WaitForChild("replacescratch"):FireClient(player)
	end
end)--]]

print("Hey, I see you're looking for some errors! If you find anything here out of the ordinary, please don't hesitate to send me a PM. Thank you!")

local module = require(script:WaitForChild("mod"))
local mapdata = require(script:WaitForChild("mapdata"))
local route = require(script:WaitForChild("route"))

local getdate = module:GetDate(tick)
local date = getdate.Date
local fr = script.Parent
local map = fr.mainframe.Frame.earth
local btns = map.Parent.btns
local bar = fr.mainframe.Bar
local gamemenu = fr.mainframe.GameMenu
local games = fr.mainframe.Games

-- scale
local max = 3
local min = 2

fr.music:Play()

-- snow

local function checksnowballs()
	for i, v in pairs(fr.mainframe.Snow:GetChildren()) do
		if v.Name ~= "EX_SB" and v.AbsolutePosition.Y >= workspace.CurrentCamera.ViewportSize.Y - 36 then
			v:Destroy()
		end
	end
end

local snow = coroutine.wrap(function()
	while true do
		wait(math.random(3, 15) / 100)
		local size = math.random(8, 16)
		local pos = math.random(0, 100) / 100
		local snowball = fr.mainframe.Snow.EX_SB:Clone()
		snowball.Parent = fr.mainframe.Snow
		snowball.Name = "snowball"
		snowball.Size = UDim2.new(0, size, 0, size)
		snowball.Position = UDim2.new(pos, 0, 0, -size)
		snowball:TweenPosition(UDim2.new(pos + (math.random(-20, 20) / 100), 0, 1, 0))
		snowball.ImageTransparency = math.random(0, 10) / 10
		checksnowballs()
	end
end)

-- map drag

local function checkpos()
	local frm = map.Parent
	local xabspos = map.AbsolutePosition.X - frm.AbsolutePosition.X
	local yabspos = map.AbsolutePosition.Y - frm.AbsolutePosition.Y
	
	if xabspos > 0 then
		map.Position = UDim2.new(0, 0, 0, yabspos)
	end
	
	if yabspos > 0 then
		map.Position = UDim2.new(0, xabspos, 0, 0)
	end
	
	if (xabspos + map.AbsoluteSize.X) < frm.AbsoluteSize.X then
		map.Position = UDim2.new(0, frm.AbsoluteSize.X - map.AbsoluteSize.X , 0, yabspos)
	end
	
	if (yabspos + map.AbsoluteSize.Y) < frm.AbsoluteSize.Y then
		map.Position = UDim2.new(0, xabspos , 0, frm.AbsoluteSize.Y - map.AbsoluteSize.Y)
	end
end

-- add continent frames

local function addfrms()
	for i, v in pairs(mapdata) do
		for x, y in pairs(v.location) do
			local newfrm = Instance.new("Frame")
			newfrm.Parent = map.Frame
			newfrm.Size = UDim2.new(y.sizeX, 0, y.sizeY, 0)
			newfrm.Position = UDim2.new(y.posX, 0,  y.posY, 0)
			newfrm.BackgroundTransparency = 1
			newfrm.Name = i
		end
	end
end

-- collision func

local function collides(gui1, gui2)
	local g1p, g1s = gui1.AbsolutePosition, gui1.AbsoluteSize
	local g2p, g2s = gui2.AbsolutePosition, gui2.AbsoluteSize
	return (g1p.x < g2p.x + g2s.x and g1p.x + g1s.x > g2p.x) and (g1p.y < g2p.y + g2s.y and g1p.y + g1s.y > g2p.y)
end

-- check santa location

local function checksanta()
	for i, v in pairs(map.Frame:GetChildren()) do
		if collides(map.santa, v) then
			bar.location.continent.Text = v.Name
			return
		end
	end
end

-- update santa

local function updatesanta()
	local utc = module:GetDate(os.time)
	--(utc.Hour, utc.Minute, utc.Second, utc.Date, utc.Month, utc.Day)
	--[[for i = 1, #route do
		map.santa:TweenPosition(UDim2.new(route[i].x, 0, route[i].y, 0), "Out", "Linear")
		wait(1.03)
	end]]
	if (utc.Date:find("Dec 24") and utc.Hour >= 11)or(utc.Date:find("Dec 25") and utc.Hour <= 13) then
		local nexthour, nextday
		if utc.Date:find("Dec 24") and utc.Hour == 23 then
			nexthour = 0
			nextday = "Dec25"
		else
			nexthour = utc.Hour + 1
			nextday = (utc.Date:gsub(" ", "")):sub(1, 5)
		end
		
		local name = {
			"Dec" .. utc.Day .. "#" .. utc.Hour,
			nextday .. "#" .. nexthour
		}
		
		print(name[1], name[2])
		
		-- pos1 + (pos2 - pos1) * (mins / 60)
		local newXpos = route[name[1]].x + (route[name[2]].x - route[name[1]].x) * (utc.Minute / 60)
		local newYpos = route[name[1]].y + (route[name[2]].y - route[name[1]].y) * (utc.Minute / 60)
		map.santa.Position = UDim2.new(newXpos, 0, newYpos, 0)
	end
end

-- setup bar

local function setupbar()
	while true do
		local getdate = module:GetDate(tick)
		bar.current:WaitForChild("time").Text = getdate.Time
		bar.current:WaitForChild("date").Text = getdate.DateYear
		updatesanta()
		wait(60 - getdate.Second)
	end
end

-- zoom in/out

btns.plus.MouseButton1Click:Connect(function()
	if map.UIScale.Scale <= max - 0.2 then
		map.UIScale.Scale = map.UIScale.Scale + 0.2
		checkpos()
	end
end)

btns.minus.MouseButton1Click:Connect(function()
	if map.UIScale.Scale >= min + 0.2 then
		map.UIScale.Scale = map.UIScale.Scale - 0.2
		checkpos()
	end
end)

-- playeradded

game.ReplicatedStorage:WaitForChild("replacesanta").OnClientEvent:Connect(function()
	map.santa.Image = "rbxassetid://1219482827"
end)

-- minigames btn clicked

bar.minigames.MouseButton1Click:Connect(function()
	if not gamemenu.Visible then
		bar.minigames.Visible = false
		bar.maps.Visible = true
		gamemenu.Position = UDim2.new(1, 0, 0, 0)
		gamemenu.Visible = true
		map.Parent:TweenPosition(UDim2.new(-0.9, 0, 0, 50))
		gamemenu:TweenPosition(UDim2.new(0, 0, 0, 0))
		wait(1)
		map.Parent.Visible = false
	end
end)

-- minigames close btn clicked

bar.maps.MouseButton1Click:Connect(function()
	if not map.Parent.Visible and #games:GetChildren() == 1 then
		bar.minigames.Visible = true
		bar.maps.Visible = false
		map.Parent.Visible = true
		gamemenu:TweenPosition(UDim2.new(1, 0, 0, 0))
		map.Parent:TweenPosition(UDim2.new(0.1, 0, 0, 50))
		wait(1)
		gamemenu.Visible = false
	end
end)

for i, v in pairs(gamemenu.games:GetChildren()) do
	if v:IsA("ImageButton") then
		v.MouseButton1Click:Connect(function()
			if #games:GetChildren() == 1 then
				local new = games.GameFiles[v.Name]:Clone()
				new.Parent = games
				for i = 1, 0, -0.05 do
					games.BackgroundTransparency = i
					wait()
				end
				wait(1)
				games[v.Name].Visible = true
				games[v.Name].Playing.Value = true
				gamemenu.Visible = false
				bar.Visible = false
				fr.mainframe.Frame.Visible = false
			end
		end)
	end
end

map:GetPropertyChangedSignal("AbsolutePosition"):Connect(checkpos)
map.santa:GetPropertyChangedSignal("AbsolutePosition"):Connect(checksanta)

-- if christmas (eve)

--if date:find("Dec") then
	-- yas
	addfrms()
	snow()
	--games.Position = UDim2.new(1, 0, 0, 0)
	fr.mainframe.Visible = true
	fr.comeback.Visible = false
	setupbar()
--[[else
	-- nop
	fr.comeback.Visible = true
	fr.mainframe.Visible = false
end]] -- disabled for devforums

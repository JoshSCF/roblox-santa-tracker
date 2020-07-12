local levels = require(script:WaitForChild("levels"))

local cs = script.Parent
local lvlbtns = cs.Levels
local main = cs.Main
local play = main.Player.Play
local plr = main.Player.PlrBG.Main
local wkspc = main.Workspace.Main

local dirs = {"^", "v", "<", ">"}
local movement = {} -- tbl representing movement of santa
local santa = nil

local playing = false
local finished = false
local failed = false

local LEVEL = 0
local code = ""

local function collides(gui1, gui2)
	local g1p, g1s = gui1.AbsolutePosition, gui1.AbsoluteSize
	local g2p, g2s = gui2.AbsolutePosition, gui2.AbsoluteSize
	return (g1p.x < g2p.x + g2s.x and g1p.x + g1s.x > g2p.x) and (g1p.y < g2p.y + g2s.y and g1p.y + g1s.y > g2p.y)
end

local function getIndex(tbl, val)
	for i, v in pairs(tbl) do
		if val == v then
			return i
		end
	end
	return nil
end

local function endgame()
	local mainframe = cs.Parent.Parent
	cs.Visible = false
	mainframe.Bar.Visible = true
	mainframe.Frame.Visible = false
	mainframe.GameMenu.Visible = true
	wait(1)
	for i = 0, 1, 0.05 do
		cs.Parent.BackgroundTransparency = i
		wait()
	end
	cs:Destroy()
end

local function showCode()
	code = "function whenStarts()\n"
	for i, v in pairs(movement) do
		local ref = {
			["<"] = "santa:MoveLeft()",
			[">"] = "santa:MoveRight()",
			["^"] = "santa:MoveUp()",
			["v"] = "santa:MoveDown()"
		}
		code = code .. "    " .. ((i ~= 1 and "wait(1)\n    ") or "") .. ref[v] .. "\n"
	end
	code = code .. "end"
	main.Code:TweenPosition(UDim2.new(0.5, -200, 0.5, -150))
	main.Code.CodeBox.Main.Text = code
end

local function fail()
	if not failed then
		failed = true
		main.FailMessage:TweenPosition(UDim2.new(0.5, -100, 0.5, -50))
		wait(3)
		endgame()
	end
end

local function complete()
	if playing then
		playing = false
		main.WinMessage:TweenPosition(UDim2.new(0.5, -125, 0.5, -50))
		game.ReplicatedStorage.awardpoints:FireServer(tonumber(LEVEL * 3))
		wait(3)
		main.WinMessage:TweenPosition(UDim2.new(0.5, -125, 1, 0))
		wait(1)
		showCode()
	end
end

local endWhenFinished = coroutine.wrap(function()
	while not finished do
		wait(1)
	end
	if collides(santa, plr.Grid.finish) then
		complete()
	else
		fail()
	end
end)

local waitForSanta = coroutine.wrap(function()
	while not santa do wait(1) end
	santa:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		for i, v in pairs(plr.Grid:GetChildren()) do
			if v.Name == "wall" then
				if collides(santa, v) then
					fail()
					pcall(function()
						santa:TweenPosition(UDim2.new(santa.Position), "Out", "Quad", 0, true)
					end)
				end
			end
		end
	end)
end)

local function genMap(lvl)
	local mapSize = #levels[lvl]
	for x, v1 in pairs(levels[lvl]) do
		for y, v2 in pairs(v1) do
			local newFrame = Instance.new("ImageLabel")
			newFrame.BackgroundColor3 = Color3.new(1, 1, 1)
			newFrame.Size = UDim2.new(1 / mapSize, 0, 1 / mapSize, 0)
			newFrame.Parent = plr.Grid
			newFrame.Position = UDim2.new((1 / mapSize) * x - 1 / mapSize, 0, (1 / mapSize) * (y - 1), 0)
			if v2 == " " then
				newFrame.ImageTransparency = 1
			elseif v2 == "S" then
				newFrame.Image = "rbxassetid://1219482940"
				santa = newFrame
				game.ReplicatedStorage.checkscratch:FireServer()
				newFrame.BackgroundTransparency = 1
				newFrame.Size = UDim2.new(1 / mapSize, -4, 1 / mapSize, -4)
				newFrame.Position = UDim2.new((1 / mapSize) * x - 1 / mapSize, 2, (1 / mapSize) * (y - 1), 2)
				newFrame.Name = "santa"
				waitForSanta()
			elseif v2 == "#" then
				newFrame.Image = "rbxassetid://1234619088"
				newFrame.Name = "wall"
			elseif v2 == "F" then
				newFrame.Image = "rbxassetid://1234637807"
				newFrame.Name = "finish"
			end
		end
	end
end

local function updatePos()
	local newPos = Vector2.new(wkspc.whenStart.AbsoluteSize.X + 64, 32 + (#wkspc:GetChildren() - 1) * 40)
	if wkspc.CanvasSize ~= UDim2.new(0, newPos.X, 0, newPos.Y) then
		wkspc.CanvasSize = UDim2.new(0, newPos.X, 0, newPos.Y)
	end
end

lvlbtns.lvlEXIT.MouseButton1Click:Connect(function()
	local mainframe = cs.Parent.Parent
	cs.Visible = false
	mainframe.Bar.Visible = true
	mainframe.Frame.Visible = false
	mainframe.GameMenu.Visible = true
	wait(1)
	for i = 0, 1, 0.05 do
		cs.Parent.BackgroundTransparency = i
		wait()
	end
	cs:Destroy()
end)

wkspc.addElement.MouseButton1Click:Connect(function()
	local newElement = wkspc.Parent.ex_move:Clone()
	newElement.Parent = wkspc
	newElement.Position = UDim2.new(0, 16, 0, 16 + 40 * (#wkspc:GetChildren() - 2))
	newElement.Name = "M" .. #wkspc:GetChildren() - 2
	newElement.Visible = true
	table.insert(movement, "^")
end)

play.MouseButton1Click:Connect(function()
	if not playing then
		endWhenFinished()
		playing = true
		for i, v in pairs(movement) do
			local pos = {
				santa.Position.X.Scale,
				santa.Size.X.Scale,
				santa.Position.Y.Scale,
				santa.Size.Y.Scale
			}
			if v == "<" then
				santa:TweenPosition(UDim2.new(pos[1] - pos[2], 2, pos[3], 2), "Out", "Quad", 1, false)
			elseif v == ">" then
				santa:TweenPosition(UDim2.new(pos[1] + pos[2], 2, pos[3], 2), "Out", "Quad", 1, false)
			elseif v == "^" then
				santa:TweenPosition(UDim2.new(pos[1], 2, pos[3] - pos[4], 2), "Out", "Quad", 1, false)
			elseif v == "v" then
				santa:TweenPosition(UDim2.new(pos[1], 2, pos[3] + pos[4], 2), "Out", "Quad", 1, false)
			end
			wait(1.4)
		end
		finished = true
	end
end)

game.ReplicatedStorage:WaitForChild("replacescratch").OnClientEvent:Connect(function()
	pcall(function()
		santa.Image = "rbxassetid://1235753527"
	end)
end)

wkspc.ChildAdded:Connect(function(des)
	updatePos()
	if des.Name == "ex_move" then
		des.direction.MouseButton1Click:Connect(function()
			local ind = getIndex(dirs, des.direction.Text)
			if ind == 4 then
				des.direction.Text = dirs[1]
			else
				des.direction.Text = dirs[ind + 1]
			end
			movement[tonumber(des.Name:sub(2))] = des.direction.Text
		end)
	end
end)

for i, v in pairs(lvlbtns:GetChildren()) do
	if v.Name ~= "lvlEXIT" and v:IsA("TextButton") then
		v.MouseButton1Click:Connect(function()
			lvlbtns.Visible = false
			main.Visible = true
			LEVEL = tonumber(v.Text)
			updatePos()
			genMap(tonumber(v.Text))
		end)
	end
end

main.Code.CodeBox.Main:GetPropertyChangedSignal("Text"):Connect(function()
	if main.Code.CodeBox.Main.Text ~= code then
		main.Code.CodeBox.Main.Text = code
	end
end)

main.Code.OK.MouseButton1Click:Connect(endgame)

--[[play:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
	local pos = UDim2.new(0.5, -(play.AbsolutePosition.X / 2), 1, -(play.AbsolutePosition.Y) - 4)
	if play.Position ~= pos then
		play.Position = pos
	end
end)]]

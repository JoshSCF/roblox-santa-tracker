math.randomseed(tick())

local fs = script.Parent
local ma = fs.MainArea
local title = fs.Title

local canStart = false
local isJumping = false
local fallRate = 0.006
local playing = false
local point = 0.5
local canJump = true
local jumpCount = 0

local function collides(gui)
	local g1p, g1s = ma.santa.AbsolutePosition, ma.santa.AbsoluteSize
	local g2p, g2s = gui.AbsolutePosition, gui.AbsoluteSize
	return (g1p.x < g2p.x + g2s.x and g1p.x + g1s.x > g2p.x) and (g1p.y < g2p.y + g2s.y and g1p.y + g1s.y > g2p.y)
end

local function incScore()
	ma.score.Text = ma.score.Text + 1
	ma.score.bk.Text = ma.score.bk.Text + 1
end

local function movepipes()
	ma.pipe1:TweenPosition(UDim2.new(-0.1, 0, 0, 0), "Out", "Linear", 5)
	ma.pipe2:TweenPosition(UDim2.new(-0.1, 0, point + 0.1, ma.santa.AbsoluteSize.Y / 2), "Out", "Linear", 5)
	wait(5.03)
	if ma.pipe1.AbsolutePosition.X < 0 then
		point = math.random(2, 8) / 10
		ma.pipe1.Size = UDim2.new(0.05, 0, point - 0.1, -(ma.santa.AbsoluteSize.Y / 2))
		ma.pipe1.Position = UDim2.new(1, 0, 0, 0)
		ma.pipe2.Position = UDim2.new(1, 0, point + 0.1, ma.santa.AbsoluteSize.Y / 2)
		incScore()
	end
end

local grav = coroutine.wrap(function()
	while wait() do
		if not isJumping then
			local pos = {
				ma.santa.Position.X.Scale,
				ma.santa.Position.X.Offset,
				ma.santa.Position.Y.Scale,
				ma.santa.Position.Y.Offset
			}
			ma.santa.Position = UDim2.new(pos[1], pos[2], pos[3] + fallRate, pos[4])
			fallRate = fallRate + 0.001
		else
			fallRate = 0.006
		end
		if not playing then
			break
		end
	end
end)

local function main()
	ma.santa:TweenPosition(UDim2.new(0.1, 0, 0.425, 0))
	ma.pipe1.Size = UDim2.new(0.05, 0, point - 0.1, -(ma.santa.AbsoluteSize.Y / 2))
	ma.pipe2.Position = UDim2.new(0.9, 0, point + 0.1, ma.santa.AbsoluteSize.Y / 2)
	wait(1)
	canStart = true
end

local function resetPipes()
	ma.pipe1:TweenPosition(ma.pipe1.Position, "Out", "Quad", 0, true)
	ma.pipe2:TweenPosition(ma.pipe2.Position, "Out", "Quad", 0, true)
end

local function endgame()
	local mainframe = fs.Parent.Parent
	fs.Visible = false
	mainframe.Bar.Visible = true
	mainframe.Frame.Visible = false
	mainframe.GameMenu.Visible = true
	wait(1)
	for i = 0, 1, 0.05 do
		fs.Parent.BackgroundTransparency = i
		wait()
	end
	fs:Destroy()
end

ma.santa:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
	if playing then
		--[[if ma.santa.AbsolutePosition.Y < 0 then
			ma.santa:TweenPosition(UDim2.new(0, ma.santa.AbsolutePosition.X, 0, ma.santa.AbsolutePosition.Y + 16))
		end]]
		if collides(fs.Ground) then
			playing = false
			resetPipes()
			wait(2)
			if tonumber(ma.score.Text) > 0 then
				game.ReplicatedStorage.awardpoints:FireServer(tonumber(ma.score.Text))
			end
			endgame()
		elseif collides(ma.pipe1) or collides(ma.pipe2) or ma.santa.AbsolutePosition.Y + ma.santa.AbsoluteSize.Y < ma.pipe1.AbsolutePosition.Y then
			resetPipes()
			canJump = false
		end
	end
end)

game:GetService("UserInputService").InputBegan:Connect(function()
	local pos = {
		ma.santa.Position.X.Scale,
		ma.santa.Position.X.Offset,
		ma.santa.Position.Y.Scale,
		ma.santa.Position.Y.Offset
	}
	if playing and canJump then
		isJumping = true
		jumpCount = jumpCount + 1
		ma.santa:TweenPosition(UDim2.new(pos[1], pos[2], pos[3] - 0.16, pos[4]), "Out", "Quad", 0.5, true)
		wait(0.5)
		jumpCount = jumpCount - 1
		if jumpCount == 0 then
			isJumping = false
		end
	end
end)

title.start.MouseButton1Click:Connect(function()
	if canStart and not playing then
		canStart = false
		title:TweenPosition(UDim2.new(0.5, -150, 1, 0))
		wait(2)
		playing = true
		grav()
		while playing do
			movepipes()
		end
	end
end)

fs.Playing.Changed:Connect(function()
	if fs.Playing.Value then
		main()
	end
end)

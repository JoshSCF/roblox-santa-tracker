local se = script.Parent
local whoseGo = 0
local playing = false
local cpu = false

local plrs = {
	santa = {"rbxassetid://1219482940", "Santa"},
	elf = {"rbxassetid://1237371812", "Elf"}
}

local function endgame(txt)
	local mainframe = se.Parent.Parent
	playing = false
	se.Winner.Title.Text = txt
	se.Winner:TweenPosition(UDim2.new(0.5, -125, 0.5, -57))
	wait(3)
	se.Visible = false
	mainframe.Bar.Visible = true
	mainframe.Frame.Visible = false
	mainframe.GameMenu.Visible = true
	wait(1)
	for i = 0, 1, 0.05 do
		se.Parent.BackgroundTransparency = i
		wait()
	end
	se:Destroy()
end

local function preload(imgs)
	local ins = {}
	for i, v in pairs(imgs) do
		local img = Instance.new("ImageLabel")
		img.Image = "rbxassetid://" .. v
		table.insert(ins, img)
		img:Destroy()
	end
	game:GetService("ContentProvider"):PreloadAsync(ins)
end

local function s(b, i, ref)
	return b["sqr" .. i].Image == ref
end

local function checkwinner(b)
	for i, v in pairs({plrs.santa, plrs.elf}) do
		if(s(b, 1, v[1]) and s(b, 2, v[1]) and s(b, 3, v[1]))or(s(b, 4, v[1]) and s(b, 5, v[1]) and s(b, 6, v[1]))or(s(b, 7, v[1]) and s(b, 8, v[1]) and s(b, 9, v[1]))or(s(b, 1, v[1]) and s(b, 4, v[1]) and s(b, 7, v[1]))or(s(b, 2, v[1]) and s(b, 5, v[1]) and s(b, 8, v[1]))or(s(b, 3, v[1]) and s(b, 6, v[1]) and s(b, 9, v[1]))or(s(b, 1, v[1]) and s(b, 5, v[1]) and s(b, 9, v[1]))or(s(b, 3, v[1]) and s(b, 5, v[1]) and s(b, 7, v[1]))then
			endgame(v[2] .. " wins!")
			return true
		end
	end
	for i = 1, 9 do
		if b["sqr" .. i].Image == "" then
			return false
		end
	end
	endgame("It's a draw!")
	return true
end

local function cpuMove(b)
	local possible = {}
	for i = 1, 9 do
		if b["sqr" .. i].Image == "" then
			table.insert(possible, b["sqr"..i])
		end
	end
	wait(math.random(5, 25) / 10)
	possible[math.random(#possible)].Image = plrs.elf[1]
	checkwinner(se.Board)
	whoseGo = 0
end

for i = 1, 9 do
	se.Board["sqr" .. i].MouseButton1Click:Connect(function()
		if playing then
			if se.Board["sqr" .. i].Image == "" then
				if whoseGo == 0 then
					se.Board["sqr" .. i].Image = plrs.santa[1]
					if not checkwinner(se.Board) then
						whoseGo = 1
						if cpu then
							cpuMove(se.Board)
						end
					end
				elseif not cpu then
					se.Board["sqr" .. i].Image = plrs.elf[1]
					checkwinner(se.Board)
					whoseGo = 0
				end
			end
		end
	end)
end

se.Start["2P"].MouseButton1Click:Connect(function()
	if not playing then
		playing = true
		se.Start:TweenPosition(UDim2.new(0.5, -200, 1, 0))
	end
end)

se.Start["CPU"].MouseButton1Click:Connect(function()
	if not playing then
		playing, cpu = true, true
		se.Start:TweenPosition(UDim2.new(0.5, -200, 1, 0))
	end
end)

preload({1237371812})

local nn = script.Parent
local canCalc = true

local function endgame()
	local mainframe = nn.Parent.Parent
	nn.Visible = false
	mainframe.Bar.Visible = true
	mainframe.Frame.Visible = false
	mainframe.GameMenu.Visible = true
	wait(1)
	for i = 0, 1, 0.05 do
		nn.Parent.BackgroundTransparency = i
		wait()
	end
	nn:Destroy()
end

local function main(sum)
	nn.NameTxtBox:TweenPosition(UDim2.new(0.5, -150, 1, 0))
	nn.CalcBtn:TweenPosition(UDim2.new(0.5, -100, 1, 0))
	wait(1)
	for i = 1, 0, -0.05 do
		wait()
		nn.percentage.TextTransparency = i
	end
	wait(0.5)
	for i = 1, sum do
		wait()
		nn.percentage.Text = i .. "%"
	end
	wait(0.5)
	nn.comment.Text = "You're " .. sum .. "% nice!"
	nn.comment:TweenPosition(UDim2.new(0, 0, 0.5, 50))
	wait(3)
	endgame()
end

nn.CalcBtn.MouseButton1Click:Connect(function()
	local txt = nn.NameTxtBox.Text:lower()
	if canCalc and txt ~= "name" then
		canCalc = false
		local sum = 0
		for i = 1, #txt do
			sum = sum + txt:byte()
		end
		main((sum % 50) + 50)
	end
end)

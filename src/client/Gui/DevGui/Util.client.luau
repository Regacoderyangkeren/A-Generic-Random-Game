-- services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- modules
local UtilConstants = require(script.Parent:WaitForChild("UtilConstants"))

-- constants
local tweenInfo = UtilConstants.DEV_GUI_TWEEN_INFO

-- variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local devGui = playerGui:WaitForChild("DevGui")
local container = devGui:WaitForChild("Container")
local button = container:WaitForChild("ExpandButton")
local mainFrame = button:WaitForChild("MainFrame")
local buttonClosedPosition = button.Position
local buttonOpenPosition = buttonClosedPosition - UDim2.fromOffset(0, 400)

button.MouseEnter:Connect(function()
	TweenService:Create(button, tweenInfo, {
		Position = buttonOpenPosition
	}):Play()

	if mainFrame.MouseEnter:Wait() then
		TweenService:Create(button, tweenInfo, {
			Position = buttonOpenPosition
		}):Play()
	end
end)

button.MouseLeave:Connect(function()
	local tween = TweenService:Create(button, tweenInfo, {
		Position = buttonClosedPosition
	})

	tween:Play()

	tween.Completed:Once(function()
	end)
end)

mainFrame.MouseLeave:Connect(function()
	local tween = TweenService:Create(button, tweenInfo, {
		Position = buttonClosedPosition
	})

	tween:Play()

	tween.Completed:Once(function()
	end)
end)

if buttonClosedPosition then 
	button.MouseClick:Connect(function()
		if button.Position == buttonClosedPosition then
			TweenService:Create(button, tweenInfo, {
				Position = buttonOpenPosition
			}):Play()
		else
			TweenService:Create(button, tweenInfo, {
				Position = buttonClosedPosition
			}):Play()
		end
	end)
end
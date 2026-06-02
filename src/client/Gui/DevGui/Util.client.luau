local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local devGui = playerGui:WaitForChild("DevGui")
local button = devGui:WaitForChild("ExpandButton")
local mainFrame = button:WaitForChild("MainFrame")

local defaultPosition = mainFrame.Position
local shownPosition = defaultPosition - UDim2.fromScale(0, 8)

local tweenInfo = TweenInfo.new(
	0.18,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

button.MouseEnter:Connect(function()
	TweenService:Create(mainFrame, tweenInfo, {
		Position = shownPosition
	}):Play()
end)

button.MouseLeave:Connect(function()
	local tween = TweenService:Create(mainFrame, tweenInfo, {
		Position = defaultPosition
	})

	tween:Play()

	tween.Completed:Once(function()
	end)
end)
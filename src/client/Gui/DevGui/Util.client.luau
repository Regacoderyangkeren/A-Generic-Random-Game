-- services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- modules
local UtilConstants = require(script.Parent:WaitForChild("UtilConstants"))

-- constants
local tweenInfo = UtilConstants.DEV_GUI_TWEEN_INFO
local hoverCloseDelay = UtilConstants.DEV_GUI_UPDATE_INTERVAL

-- variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local devGui = playerGui:WaitForChild("DevGui")
local container = devGui:WaitForChild("Container")
local button = container:WaitForChild("ExpandButton")
local mainFrame = button:WaitForChild("MainFrame")

local buttonClosedPosition = button.Position
local buttonOpenPosition = buttonClosedPosition - UDim2.fromOffset(0, 400)

local isOpen = false
local isButtonHovered = false
local isMainFrameHovered = false
local suppressHoverOpen = false

-- connection for the hover tween, so it can be cancelled if the state changes before the tween finishes
local activeTween = nil
-- used to track hover close requests, so that if multiple requests are made in quick succession, only the last one will actually close the menu
local closeRequestId = 0

-- ensure the main frame doesn't block mouse input to the button and that it doesn't clip its contents, so that the UI can function properly when open
button.ClipsDescendants = false

-- function to tween the button to a specified position, used for both opening and closing the dev GUI with a smooth animation
local function tweenButton(position)
	if activeTween then
		activeTween:Cancel()
	end

	activeTween = TweenService:Create(button, tweenInfo, {
		Position = position
	})

	activeTween:Play()
end

-- returns whether the dev GUI is currently hovered by the mouse.
local function isHovered()
	return isButtonHovered or isMainFrameHovered
end

-- local function to open the dev GUI visually
local function open()
	tweenButton(buttonOpenPosition)
end

-- local function to close the dev GUI visually
local function close()
	tweenButton(buttonClosedPosition)
end

-- requests the dev GUI to close after a short delay, but only if the mouse isn't hovering over it by the time the delay is up.
local function requestClose()
	closeRequestId += 1
	local currentRequestId = closeRequestId

	task.delay(hoverCloseDelay, function()
		if currentRequestId ~= closeRequestId then
			return
		end

		if isHovered() then
			return
		end

		suppressHoverOpen = false

		if isOpen then
			return
		end

		close()
	end)
end

-- hovering over the button will open the dev GUI
button.MouseEnter:Connect(function()
	isButtonHovered = true

	if suppressHoverOpen then
		return
	end

	open()
end)

-- hovering off the button will request it to close after a delay, to allow time for the mouse to move to the main frame without immediately closing the menu.
button.MouseLeave:Connect(function()
	isButtonHovered = false
	requestClose()
end)

-- hovering over the main frame keeps it open
mainFrame.MouseEnter:Connect(function()
	isMainFrameHovered = true

	if suppressHoverOpen then
		return
	end

	open()
end)

mainFrame.MouseLeave:Connect(function()
	isMainFrameHovered = false
	requestClose()
end)

-- clicking the button toggles the dev GUI
button.Activated:Connect(function()
	-- if hover was manually closed, clicking again should open it
	if suppressHoverOpen then
		suppressHoverOpen = false
		isOpen = true
		open()
		return
	end

	-- if it is clicked open OR hover-open, clicking closes it
	if isOpen or isHovered() then
		isOpen = false
		suppressHoverOpen = true
		close()
	else
		isOpen = true
		suppressHoverOpen = false
		open()
	end
end)
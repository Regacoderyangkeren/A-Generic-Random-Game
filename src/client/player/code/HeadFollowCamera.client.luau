-- thank you youtube, you're the goat frfr. Got this stuff mostly from: https://www.youtube.com/watch?v=s2RaeG_DiVw
-- services
local runService = game:GetService("RunService")
local playerService = game:GetService("Players")

-- modules
local headFollowDebug = require(script.Parent.Parent:WaitForChild("debug"):WaitForChild("HeadFollowCameraDebug"))

-- constants
local headHorizontalFactor = 1
local headVerticalFactor = .6
local updateSpeed = .5 / 2

-- variables
local player = playerService.LocalPlayer
local camera = workspace.CurrentCamera

-- connection for updating the camera
local renderConnection: RBXScriptConnection? = nil

local function setupCharacter(char: Model)
	-- disconnect previous connection if it exists
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end

	-- wait for the necessary parts to load
	local humanoid = char:WaitForChild("Humanoid")
	local head = char:WaitForChild("Head")
	local torso = char:WaitForChild("Torso")
	local neck = torso:WaitForChild("Neck")

	if not neck:IsA("Motor6D") then
		return
	end

	-- store the original C0 of the neck and set max velocity for smooth interpolation
	local neckC0 = neck.C0
	neck.MaxVelocity = 1 / 3

	headFollowDebug.Bind({
		character = char,
		humanoid = humanoid,
		head = head,
		torso = torso,
		neck = neck,
		neckC0 = neckC0,

		headHorizontalFactor = headHorizontalFactor,
		headVerticalFactor = headVerticalFactor,
		updateSpeed = updateSpeed,
	})

	-- connect to RenderStepped to update the neck's C0 based on the camera's position relative to the head
	renderConnection = runService.RenderStepped:Connect(function()
		if torso and head and neck and camera.CameraSubject == humanoid then
			local cameraCF = camera.CFrame
			local headCF = head.CFrame
			local torsoLV = torso.CFrame.LookVector

			local dist = (headCF.Position - cameraCF.Position).Magnitude
			local diff = headCF.Y - cameraCF.Y

			local asinDiffDist = math.asin(diff / dist)
			local headCross = ((headCF.Position - cameraCF.Position).Unit:Cross(torsoLV)).Y

			neck.C0 = neck.C0:Lerp(
				neckC0 * CFrame.Angles(-1 * asinDiffDist * headVerticalFactor, 0, -1 * headCross * headHorizontalFactor),
				updateSpeed
			)
		end
	end)
end

if player.Character then
	setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

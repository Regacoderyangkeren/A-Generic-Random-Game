-- thank you youtube, you're the goat frfr. Got this stuff mostly from: https://www.youtube.com/watch?v=s2RaeG_DiVw
-- services
local runService = game:GetService("RunService")
local playerService = game:GetService("Players")

-- modules
local constants = require(script.Parent.Parent:WaitForChild("constants"):WaitForChild("HeadFollowCameraConstants"))
local headFollowDebug = require(script.Parent.Parent:WaitForChild("debug"):WaitForChild("HeadFollowCameraDebug"))

-- constants
local headHorizontalFactor = constants.HEAD_HORIZONTAL_FACTOR
local headVerticalFactor = constants.HEAD_VERTICAL_FACTOR
local updateSpeed = constants.UPDATE_SPEED

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
	renderConnection = runService.RenderStepped:Connect(function(deltaTime)
		camera = workspace.CurrentCamera

		if not camera then
			return
		end

		-- only update the neck if the camera's subject is the humanoid, and all necessary parts are available, to ensure we are controlling the correct character's head
		if torso and head and neck and camera.CameraSubject == humanoid then
			local cameraCF = camera.CFrame
			local headCF = head.CFrame
			local torsoLV = torso.CFrame.LookVector

			local headToCamera = headCF.Position - cameraCF.Position
			local dist = headToCamera.Magnitude

			if dist <= 0.001 then
				return
			end

			local diff = headCF.Position.Y - cameraCF.Position.Y

			local asinDiffDist = math.asin(math.clamp(diff / dist, -1, 1))
			local headCross = headToCamera.Unit:Cross(torsoLV).Y

			local targetC0 = neckC0 * CFrame.Angles(
				-asinDiffDist * headVerticalFactor,
				0,
				-headCross * headHorizontalFactor
			)

			local alpha = 1 - math.pow(1 - updateSpeed, deltaTime * 60)

			neck.C0 = neck.C0:Lerp(targetC0, alpha)
		end
	end)
end

if player.Character then
	setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

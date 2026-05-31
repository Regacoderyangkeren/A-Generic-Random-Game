-- thank you youtube, you're the goat frfr. Got this stuff mostly from: https://www.youtube.com/watch?v=s2RaeG_DiVw
-- services
local runService = game:GetService("RunService")
local playerService = game:GetService("Players")

-- constants
local headHorizontalFactor = 1
local headVerticalFactor = .6
local updateSpeed = .5 / 2

local debugOutput = true
local debugInterval = 0.25
local debugTimer = 0

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

	-- connect to RenderStepped to update the neck's C0 based on the camera's position relative to the head
	renderConnection = runService.RenderStepped:Connect(function(deltaTime)
		if torso and head and neck and camera.CameraSubject == humanoid then
			local cameraCF = camera.CFrame
			local headCF = head.CFrame
			local torsoLV = torso.CFrame.LookVector

			-- debug output for camera and head orientation
			debugTimer += deltaTime

			-- output the camera's yaw and pitch relative to the character, as well as the world and head look vectors, at the specified debug interval
			if debugOutput and debugTimer >= debugInterval then
				debugTimer = 0

				local cameraLook = cameraCF.LookVector
				local headLook = headCF.LookVector

				-- Camera direction relative to the character's torso
				local relativeCameraLook = torso.CFrame:VectorToObjectSpace(cameraLook)

				local yaw = math.deg(math.atan2(relativeCameraLook.X, -relativeCameraLook.Z))
				local pitch = math.deg(math.asin(relativeCameraLook.Y))

				print(string.format(
					"Camera looking | Yaw: %.1f° | Pitch: %.1f° | World LookVector: %.2f, %.2f, %.2f | Head LookVector: %.2f, %.2f, %.2f",
					yaw,
					pitch,
					cameraLook.X,
					cameraLook.Y,
					cameraLook.Z,
					headLook.X,
					headLook.Y,
					headLook.Z
				))
			end

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

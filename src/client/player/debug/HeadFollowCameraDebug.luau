--!strict

-- services
local clientRoot = script.Parent.Parent.Parent

-- modules
local debugRegistry = require(clientRoot:WaitForChild("debug"):WaitForChild("DebugRegistry"))
local debugFormat = require(clientRoot.debug:WaitForChild("DebugFormatUtil"))

-- constants
local HeadFollowDebug = {}

-- variables
local data = {
	character = nil :: Model?,
	humanoid = nil :: Humanoid?,
	head = nil :: BasePart?,
	torso = nil :: BasePart?,
	neck = nil :: Motor6D?,
	neckC0 = nil :: CFrame?,

	headHorizontalFactor = 1,
	headVerticalFactor = 0.6,
	updateSpeed = 0.25,
}

-- binds the head follow debug system to a specific character and its relevant parts, as well as configuration for how the head should follow the camera,
function HeadFollowDebug.Bind(config: {
	character: Model,
	humanoid: Humanoid,
	head: BasePart,
	torso: BasePart,
	neck: Motor6D,
	neckC0: CFrame,

	headHorizontalFactor: number,
	headVerticalFactor: number,
	updateSpeed: number,
})
	data.character = config.character
	data.humanoid = config.humanoid
	data.head = config.head
	data.torso = config.torso
	data.neck = config.neck
	data.neckC0 = config.neckC0

	data.headHorizontalFactor = config.headHorizontalFactor
	data.headVerticalFactor = config.headVerticalFactor
	data.updateSpeed = config.updateSpeed
end

-- debug text object for displaying info in-game
debugRegistry.RegisterSection({
	-- unique identifier for this debug section
	id = "head-follow",
	title = "Head Follow",
	interval = 0.25,

	-- function that returns the rows of debug information to display, called at the specified interval
	getRows = function()
		local camera = workspace.CurrentCamera

		-- if the camera is missing, return a single row indicating the issue
		if not camera then
			return {
				{
					id = "camera",
					label = "Camera",
					value = "Missing",
					ok = false,
				},
			}
		end

		-- bunch of checks to make sure all necessary data is available, returning an error row if anything is missing
		local humanoid = data.humanoid
		local head = data.head
		local torso = data.torso
		local neck = data.neck
		local neckC0 = data.neckC0

		-- if any of the required parts or data is missing, return a single row indicating that the head follow debug info is not bound properly
		if not humanoid or not head or not torso or not neck or not neckC0 then
			return {
				{
					id = "bound",
					label = "Bound",
					value = "false",
					ok = false,
				},
			}
		end

		-- calculate the camera's position and orientation relative to the head and torso, and return a list of debug rows with this information for display in the debug UI
		local cameraCF = camera.CFrame
		local headCF = head.CFrame
		local torsoCF = torso.CFrame

		local cameraLook = cameraCF.LookVector
		local headLook = headCF.LookVector
		local torsoLook = torsoCF.LookVector

		-- convert the camera's look vector into the local space of the torso to determine how the head should rotate to follow the camera,
		-- and calculate angles and distances for debug display
		local relativeCameraLook = torsoCF:VectorToObjectSpace(cameraLook)

		-- calculate yaw and pitch angles from the relative camera look vector, as well as the distance from the head to the camera and the vertical angle difference,
		-- which will be used to determine how much the neck should rotate to follow the camera
		local yaw = math.deg(math.atan2(relativeCameraLook.X, -relativeCameraLook.Z))
		local pitch = math.deg(math.asin(math.clamp(relativeCameraLook.Y, -1, 1)))

		local headToCamera = headCF.Position - cameraCF.Position
		local distance = headToCamera.Magnitude
		local verticalDifference = headCF.Position.Y - cameraCF.Position.Y

		-- calculate the vertical angle difference and horizontal cross product for determining neck rotation,
		-- with checks to avoid division by zero when the camera is very close to the head
		local asinDiffDist = 0
		local headCross = 0

		-- only calculate the angles if the camera is a reasonable distance from the head to avoid issues with very close distances
		-- causing erratic angles due to small positional differences
		if distance > 0.001 then
			asinDiffDist = math.asin(math.clamp(verticalDifference / distance, -1, 1))
			headCross = headToCamera.Unit:Cross(torsoLook).Y
		end

		-- calculate the target X and Z rotation angles for the neck based on the vertical angle difference and horizontal cross product,
		-- multiplied by the respective factors for tuning the head movement
		local targetX = -asinDiffDist * data.headVerticalFactor
		local targetZ = -headCross * data.headHorizontalFactor

		-- return a list of rows to display in the debug UI, including camera subject, angles, vectors, and neck C0 position
		return {
			{
				id = "camera-subject",
				label = "Camera Subject Is Humanoid",
				value = tostring(camera.CameraSubject == humanoid),
				raw = camera.CameraSubject == humanoid,
				ok = camera.CameraSubject == humanoid,
			},

			{
				id = "yaw",
				label = "Camera Yaw",
				value = debugFormat.Round(yaw, 1) .. " deg",
				raw = yaw,
				ok = true
			},

			{
				id = "pitch",
				label = "Camera Pitch",
				value = debugFormat.Round(pitch, 1) .. " deg",
				raw = pitch,
			},

			{
				id = "camera-look",
				label = "Camera LookVector",
				value = debugFormat.Vector3(cameraLook),
				raw = cameraLook,
			},

			{
				id = "head-look",
				label = "Head LookVector",
				value = debugFormat.Vector3(headLook),
				raw = headLook,
			},

			{
				id = "distance",
				label = "Head-Camera Distance",
				value = debugFormat.Round(distance, 2),
				raw = distance,
			},

			{
				id = "vertical-angle",
				label = "Vertical Angle",
				value = debugFormat.Degrees(asinDiffDist),
				raw = asinDiffDist,
			},

			{
				id = "head-cross",
				label = "Horizontal Cross",
				value = debugFormat.Round(headCross, 3),
				raw = headCross,
			},

			{
				id = "target-x",
				label = "Target X Rotation",
				value = debugFormat.Degrees(targetX),
				raw = targetX,
			},

			{
				id = "target-z",
				label = "Target Z Rotation",
				value = debugFormat.Degrees(targetZ),
				raw = targetZ,
			},

			{
				id = "neck-c0",
				label = "Neck C0 Position",
				value = debugFormat.Vector3(neck.C0.Position),
				raw = neck.C0,
			},
		}
	end,
})

return HeadFollowDebug

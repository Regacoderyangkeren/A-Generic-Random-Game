--!strict

-- services
local RunService = game:GetService("RunService")

-- modules
local clientRoot = script.Parent.Parent.Parent
local DebugRegistry = require(clientRoot.debug:WaitForChild("DebugRegistry"))


DebugRegistry.Updated:Connect(function(sections)
	for _, section in sections do
		print("DEBUG SECTION:", section.title)

		for _, row in section.rows do
			print(row.label .. ":", row.value)
		end
	end
end)

-- connect to RenderStepped to update the debug registry every frame, allowing it to manage timers and update debug sections as needed
RunService.RenderStepped:Connect(function(deltaTime)
	DebugRegistry.Step(deltaTime)
end)

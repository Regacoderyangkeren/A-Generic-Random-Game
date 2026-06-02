--!strict

local RunService = game:GetService("RunService")

local clientRoot = script.Parent.Parent
local DebugRegistry = require(clientRoot.debug:WaitForChild("DebugRegistry"))

DebugRegistry.Updated:Connect(function(sections)
	for _, section in sections do
		print("DEBUG SECTION:", section.title)

		for _, row in section.rows do
			print(row.label .. ":", row.value)
		end
	end
end)

RunService.RenderStepped:Connect(function(deltaTime)
	DebugRegistry.Step(deltaTime)
end)
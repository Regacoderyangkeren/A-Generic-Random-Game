--!strict

local runService = game:GetService("RunService")

local debugRegistry = require(script.Parent:WaitForChild("DebugRegistry"))

debugRegistry.Updated:Connect(function(sections)
	for _, section in sections do
		print("DEBUG SECTION:", section.title)

		for _, row in section.rows do
			print(row.label .. ":", row.value)
		end
	end
end)

runService.RenderStepped:Connect(function(deltaTime)
	debugRegistry.Step(deltaTime)
end)
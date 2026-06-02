--!strict

local DebugRegistry = {}

export type DebugRow = {
	id: string,
	label: string,
	value: string,
	raw: any?,
	ok: boolean?,
}

export type DebugSection = {
	id: string,
	title: string,
	enabled: boolean,
	rows: { DebugRow },
}

type DebugEntry = {
	id: string,
	title: string,
	enabled: boolean,
	interval: number,
	timer: number,
	getRows: () -> { DebugRow },
}

local updatedEvent = Instance.new("BindableEvent")

local entries: { [string]: DebugEntry } = {}
local globalEnabled = true

DebugRegistry.Updated = updatedEvent.Event

function DebugRegistry.RegisterSection(config: {
	id: string,
	title: string,
	interval: number?,
	getRows: () -> { DebugRow },
})
	entries[config.id] = {
		id = config.id,
		title = config.title,
		enabled = true,
		interval = config.interval or 0.25,
		timer = 0,
		getRows = config.getRows,
	}
end

function DebugRegistry.UnregisterSection(id: string)
	entries[id] = nil
end

function DebugRegistry.SetEnabled(isEnabled: boolean)
	globalEnabled = isEnabled
end

function DebugRegistry.IsEnabled(): boolean
	return globalEnabled
end

function DebugRegistry.SetSectionEnabled(id: string, isEnabled: boolean)
	local entry = entries[id]

	if entry then
		entry.enabled = isEnabled
	end
end

function DebugRegistry.ToggleSection(id: string)
	local entry = entries[id]

	if entry then
		entry.enabled = not entry.enabled
	end
end

function DebugRegistry.GetChecklistDefinitions()
	local list = {}

	for _, entry in entries do
		table.insert(list, {
			id = entry.id,
			label = entry.title,
			checked = entry.enabled,
		})
	end

	return list
end

function DebugRegistry.GetSections(): { DebugSection }
	local sections: { DebugSection } = {}

	if not globalEnabled then
		return sections
	end

	for _, entry in entries do
		if entry.enabled then
			local enabled: boolean = entry.enabled
			local success, rows = pcall(entry.getRows)

			if success then
				table.insert(sections, {
					id = entry.id,
					title = entry.title,
					enabled = enabled,
					rows = rows,
				})
			else
				table.insert(sections, {
					id = entry.id,
					title = entry.title,
					enabled = enabled,
					rows = {
						{
							id = "error",
							label = "Error",
							value = tostring(rows),
							ok = false,
						},
					},
				})
			end
		end
	end

	return sections
end

function DebugRegistry.Step(deltaTime: number)
	if not globalEnabled then
		return
	end

	local shouldUpdate = false

	for _, entry in entries do
		if entry.enabled then
			entry.timer += deltaTime

			if entry.timer >= entry.interval then
				entry.timer = 0
				shouldUpdate = true
			end
		end
	end

	if shouldUpdate then
		updatedEvent:Fire(DebugRegistry.GetSections())
	end
end

return DebugRegistry
--!strict
-- DebugRegistry, for managing debug sections and rows, and firing updates when they change.
local DebugRegistry = {}

-- Types
export type DebugRow = {
	id: string,
	label: string,
	value: string,
	raw: any?,
	ok: boolean?,
}

-- DebugSection represents a section in the debug UI, containing multiple rows of debug information.
export type DebugSection = {
	id: string,
	title: string,
	enabled: boolean,
	rows: { DebugRow },
}

-- DebugEntry represents an internal entry in the DebugRegistry, containing configuration and state for a debug section.
type DebugEntry = {
	id: string,
	title: string,
	enabled: boolean,
	interval: number,
	timer: number,
	getRows: () -> { DebugRow },
}

-- BindableEvent used to signal when debug sections are updated, allowing the UI to refresh accordingly.
local updatedEvent = Instance.new("BindableEvent")

-- Internal storage for debug entries, mapping section IDs to their corresponding DebugEntry.
local entries: { [string]: DebugEntry } = {}
local globalEnabled = true

-- Expose the Updated event to allow external listeners (like the debug UI) to react to changes in the debug sections.
DebugRegistry.Updated = updatedEvent.Event

-- Registers a new debug section with the provided configuration, allowing it to be displayed and updated in the debug UI.
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

-- Unregisters a debug section by its ID, removing it from the registry and preventing it from being displayed in the debug UI.
function DebugRegistry.UnregisterSection(id: string)
	entries[id] = nil
end

-- Enables or disables the entire debug system, affecting all sections and rows. When disabled, no debug information will be displayed or updated.
function DebugRegistry.SetEnabled(isEnabled: boolean)
	globalEnabled = isEnabled
end

-- Returns whether the debug system is currently enabled, allowing external code to check if debug information will be displayed and updated.
function DebugRegistry.IsEnabled(): boolean
	return globalEnabled
end

-- Enables or disables a specific debug section by its ID, allowing for granular control over which sections are active and displayed in the debug UI.
function DebugRegistry.SetSectionEnabled(id: string, isEnabled: boolean)
	local entry = entries[id]

	if entry then
		entry.enabled = isEnabled
	end
end

-- Toggles the enabled state of a specific debug section by its ID, allowing for quick switching of sections on and off in the debug UI.
function DebugRegistry.ToggleSection(id: string)
	local entry = entries[id]

	if entry then
		entry.enabled = not entry.enabled
	end
end

-- Retrieves a list of checklist definitions for all registered debug sections, providing information about their IDs, labels, and enabled states for use in the debug UI.
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

-- Retrieves the current sections and their rows for all enabled debug entries, allowing the debug UI to display the latest debug information.
-- If an error occurs while fetching rows, it will include an error row instead.
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

-- Steps the debug registry, updating timers for each entry and firing an update event if any entries have reached their update interval,
-- allowing the debug UI to refresh with new information.
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
--!strict

-- DebugRow represents a single row of debug information, containing an ID, label, value, and optional raw data and status.
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
export type DebugEntry = {
	id: string,
	title: string,
	enabled: boolean,
	interval: number,
	timer: number,
	getRows: () -> { DebugRow },
}

-- DebugChecklist represents one toggle/checklist item for enabling or disabling a debug section.
export type DebugChecklist = {
	id: string,
	label: string,
	checked: boolean,
}

return nil
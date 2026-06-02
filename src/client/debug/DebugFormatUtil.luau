--!strict

local DebugFormatUtil = {}

-- Format utility to round numbers to a specified number of decimal places, defaulting to 2 if not provided.
function DebugFormatUtil.Round(value: number, decimals: number?): string
	decimals = decimals or 2
	return string.format("%." .. tostring(decimals) .. "f", value)
end

-- Format utility to convert a Vector3 into a string representation with each component rounded to a specified number of decimal places.
function DebugFormatUtil.Vector3(vector: Vector3): string
	return DebugFormatUtil.Round(vector.X)
		.. ", "
		.. DebugFormatUtil.Round(vector.Y)
		.. ", "
		.. DebugFormatUtil.Round(vector.Z)
end

-- Format utility to convert radians into degrees and format it as a string with a degree symbol, rounding to 1 decimal place for readability.
function DebugFormatUtil.Degrees(radians: number): string
	return DebugFormatUtil.Round(math.deg(radians), 1) .. " deg"
end

return DebugFormatUtil
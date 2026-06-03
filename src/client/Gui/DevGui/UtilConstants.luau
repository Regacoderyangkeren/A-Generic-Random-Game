--!strict
local DevGuiConstants = {}

-- cooldown / interval for updating the dev GUI, in seconds
DevGuiConstants.DEV_GUI_UPDATE_INTERVAL = 0.5

-- tween constants for the dev GUI
DevGuiConstants.DEV_GUI_TWEEN_DURATION = 0.18

DevGuiConstants.DEV_GUI_TWEEN_INFO = TweenInfo.new(
	DevGuiConstants.DEV_GUI_TWEEN_DURATION,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

return table.freeze(DevGuiConstants)
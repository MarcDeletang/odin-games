package game

import "core:strings"
import rl "vendor:raylib"

init_screen :: proc(
	title: string = "Default title",
	full_screen: bool,
	screen_height: i32 = 800,
	screen_width: i32 = 600,
) -> (
	i32,
	i32,
) {
	local_height: i32 = screen_height
	local_width: i32 = screen_width

	// We init first to grab the monitor
	rl.InitWindow(10, 10, strings.clone_to_cstring(title))
	monitor := rl.GetCurrentMonitor()

	if (full_screen) {
		local_height = rl.GetMonitorHeight(monitor)
		local_width = rl.GetMonitorWidth(monitor)
	}
	rl.SetWindowSize(local_width, local_height)
	if (full_screen) {
		rl.ToggleFullscreen()
	}
	return local_height, local_width
}

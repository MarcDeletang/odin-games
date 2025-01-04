package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

init_overlay :: proc() {}

display_overlay :: proc() {
	// Display the number of logs in the top-right corner of the screen
	logs_text := fmt.aprint("Logs: ", logs_count)
	screen_width := rl.GetScreenWidth()
	rl.GuiLabel(
		rl.Rectangle {
			x      = cast(f32)(screen_width - 200), // Position near the top-right corner
			y      = 10.0, // Padding from the top
			width  = 190.0, // Enough width for the label
			height = 30.0, // Height for the label
		},
		strings.clone_to_cstring(logs_text),
	)

	// Display the QUIT button at the bottom center of the screen
	button_width: f32 = 150.0
	button_height: f32 = 40.0
	button_x := cast(f32)(screen_width / 2) - (button_width / 2)
	button_y := cast(f32)(f32(rl.GetScreenHeight()) - button_height - 10) // Padding from the bottom

	if rl.GuiButton(
		rl.Rectangle{x = button_x, y = button_y, width = button_width, height = button_height},
		"QUIT",
	) {
		rl.CloseWindow() // Close the game window if the button is pressed
	}
}

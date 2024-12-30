package game

import "core:fmt"
import rl "vendor:raylib"

ground_color := rl.Color{22, 143, 6, 255}
river_color := rl.Color{0, 7, 153, 255}
tree_color := rl.Color{112, 75, 1, 255}
tree_cut_color := rl.Color{214, 124, 0, 255}
tree_over_river_color := rl.Color{214, 124, 0, 255}
beaver_color := rl.Color{0, 0, 0, 255}
bush_color := rl.Color{214, 124, 0, 255}
MAP_SIZE :: 64
game_map: [MAP_SIZE][MAP_SIZE]TileType
game_pos := [2]int{10, 10} // Game grid position (int)
screen_pos := [2]f32{10.0, 10.0} // Screen position (float, smooth)
logs_count := 0
move_interval := 0.1

TileType :: enum {
	GROUND,
	RIVER,
	TREE,
	TREE_CUT,
	TREE_OVER_RIVER,
	BUSH,
}

blocking_tiles := map[TileType]bool {
	.RIVER    = true,
	.TREE     = true,
	.TREE_CUT = true,
	.BUSH     = true,
}

color_mapping := map[TileType]rl.Color {
	.GROUND          = ground_color,
	.RIVER           = river_color,
	.TREE            = tree_color,
	.TREE_CUT        = tree_cut_color,
	.TREE_OVER_RIVER = tree_color,
	.BUSH            = bush_color,
}

is_invalid_pos :: proc() -> bool {
	if game_pos.y < 0 || game_pos.x < 0 || game_pos.y > MAP_SIZE || game_pos.x > MAP_SIZE {
		return true
	}
	tile := game_map[game_pos.y][game_pos.x]
	if tile == .RIVER && logs_count > 0 {
		game_map[game_pos.y][game_pos.x] = .TREE_OVER_RIVER
		logs_count -= 1
	}
	return tile in blocking_tiles
}

check_for_tree :: proc() {
	// Loop through surrounding tiles (8 directions)
	for dy in -1 ..< 2 {
		for dx in -1 ..< 2 {
			if dy == 0 && dx == 0 {
				continue // Skip the current tile
			}

			adj_x := game_pos.x + dx
			adj_y := game_pos.y + dy

			// Check if the adjacent position is within bounds
			if adj_x >= 0 && adj_x < 64 && adj_y >= 0 && adj_y < 64 {
				if game_map[adj_y][adj_x] == TileType.TREE {
					fmt.println("Tree found at:", adj_x, adj_y)
					game_map[adj_y][adj_x] = TileType.TREE_CUT
					logs_count += 1
					// Handle the action when a tree is found (e.g., print a message, pick up the tree, etc.)
				}
			}
		}
	}
}

check_beaver :: proc(last_move_time: f64) -> f64 {
	old_pos := game_pos
	current_time := rl.GetTime()
	has_moved := false

	// If the move interval hasn't passed, do nothing
	if current_time - last_move_time < move_interval {
		return last_move_time
	}

	if is_space() {
		// fmt.printfln("space!")
		check_for_tree()
	}
	if is_left() {
		has_moved = true
		game_pos.x -= 1
	}
	if is_right() {
		has_moved = true
		game_pos.x += 1
	}
	if is_up() {
		has_moved = true
		game_pos.y -= 1
	}
	if is_down() {
		has_moved = true
		game_pos.y += 1
	}

	if has_moved && is_invalid_pos() {
		// Revert the beaver's position if it is invalid
		game_pos = old_pos
	}

	return has_moved ? current_time : last_move_time
}

update_screen_pos :: proc(last_move_time: f64) {
	move_speed := 10 // Adjust movement speed (pixels per second)

	// Smoothly interpolate screen position towards the game position
	screen_pos.x +=
		(cast(f32)game_pos.x - screen_pos.x) * cast(f32)move_speed * cast(f32)rl.GetFrameTime()
	screen_pos.y +=
		(cast(f32)game_pos.y - screen_pos.y) * cast(f32)move_speed * cast(f32)rl.GetFrameTime()
}


main :: proc() {
	monitor := rl.GetCurrentMonitor()
	rl.InitWindow(800, 800, "Smooth Beaver Movement")
	screen_height := 800
	screen_width := 800
	tile_height := cast(f32)screen_height / 64
	tile_width := cast(f32)screen_width / 64
	size := rl.Vector2{cast(f32)tile_width, cast(f32)tile_height}

	init()

	last_move_time := rl.GetTime()
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		// Update the beaver's grid position
		last_move_time = check_beaver(last_move_time)

		// Update the smooth screen position
		update_screen_pos(last_move_time)


		// Render the tiles
		for y in 0 ..< MAP_SIZE {
			for x in 0 ..< MAP_SIZE {
				tile_x := cast(f32)x * tile_width
				tile_y := cast(f32)y * tile_height
				rl.DrawRectangleV({tile_x, tile_y}, size, color_mapping[game_map[y][x]])
			}
		}

		// Calculate the smooth beaver screen position
		tile_x := screen_pos.x * tile_width
		tile_y := screen_pos.y * tile_height
		rl.DrawRectangleV({tile_x, tile_y}, size, beaver_color)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}

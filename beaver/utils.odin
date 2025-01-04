package game
import rl "vendor:raylib"

is_space :: proc() -> bool {
	return rl.IsKeyDown(.SPACE)
}

is_up :: proc() -> bool {
	return rl.IsKeyDown(.UP) || rl.IsKeyDown(rl.KeyboardKey.W)
}

is_down :: proc() -> bool {
	return rl.IsKeyDown(.DOWN) || rl.IsKeyDown(rl.KeyboardKey.S)
}

is_left :: proc() -> bool {
	return rl.IsKeyDown(.LEFT) || rl.IsKeyDown(rl.KeyboardKey.A)
}

is_right :: proc() -> bool {
	return rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(rl.KeyboardKey.D)
}

init :: proc() {
	for y in 0 ..< MAP_SIZE {
		for x in 0 ..< MAP_SIZE {
			game_map[y][x] = TileType.GROUND
			if (y == 32) {
				game_map[y][x] = TileType.RIVER
			}
		}
	}
	game_map[0][0] = TileType.TREE
	game_map[20][30] = TileType.TREE
	game_map[25][35] = TileType.TREE
}

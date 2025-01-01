package main

import "core:fmt"
import "core:math"
import glm "core:math/linalg"
import rng "core:math/rand"
import rl "vendor:raylib"

G: f32 : 9e-10
BODY_MASS: f32 : 1_000
BODY_COLOR: rl.Color : {255, 255, 255, 255}

Body :: struct {
	pos: [2]f32,
}

Game :: struct {
	bodies: [dynamic]Body,
}

update :: proc(game: ^Game) {
	if len(game.bodies) == 0 do return
}

render :: proc(game: ^Game, camera: rl.Camera2D) {
	rl.BeginDrawing()
	rl.ClearBackground({20, 20, 20, 255})
	rl.BeginMode2D(camera)

	if len(game.bodies) != 0 {
		for body, index in game.bodies {
			rl.DrawPixel(i32(body.pos.x), i32(body.pos.y), BODY_COLOR)
		}
	}

	rl.EndMode2D()
	rl.EndDrawing()
}

main :: proc() {
	rl.InitWindow(800, 600, "Space Simulator");defer rl.CloseWindow()

	camera := rl.Camera2D {
		offset   = {400, 300},
		target   = {0, 0},
		zoom     = 1,
		rotation = 0,
	}

	game := Game {
		bodies = make([dynamic]Body),
	}

	for !rl.WindowShouldClose() {
		render(&game, camera)
	}
}

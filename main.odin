package main

import "core:fmt"
import "core:math"
import glm "core:math/linalg"
import rng "core:math/rand"
import rl "vendor:raylib"

WINDOW_WIDTH: i32 : 800
WINDOW_HEIGHT: i32 : 600
FPS: i32 : 60

G: f32 : 9e-8
MIN_DIST: f32 : 3.0

MAX_BODIES: i32 : 100
BODY_MASS: f32 : 1_000
BODY_COLOR: rl.Color : {255, 255, 255, 255}

Body :: struct {
	pos: [2]f32,
	vel: [2]f32,
}

Game :: struct {
	bodies:        [MAX_BODIES]Body,
	should_update: bool,
}

vec2_direction :: proc(vec_1, vec_2: [2]f32) -> [2]f32 {
	return [2]f32{vec_2.x - vec_1.x, vec_2.y - vec_1.y}
}

vec2_force :: proc(pos, dir: [2]f32, dist: f32) -> [2]f32 {
	return dir * (G * (BODY_MASS * BODY_MASS) / math.pow(dist, 2))
}

update :: proc(game: ^Game) {
	if len(game.bodies) < 2 do return

	for &top_body, top_index in game.bodies {
		for low_body, low_index in game.bodies {
			if top_index == low_index do continue

			dist := glm.distance(top_body.pos, low_body.pos)
			dir := vec2_direction(top_body.pos, low_body.pos)
			dir_norm := glm.normalize(dir)

			force := vec2_force(top_body.pos, dir_norm, dist if dist > MIN_DIST else MIN_DIST)

			top_body.vel += force
		}
		top_body.pos += top_body.vel
	}
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
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Space Simulator");defer rl.CloseWindow()
	rl.SetTargetFPS(FPS)

	camera := rl.Camera2D {
		offset   = {400, 300},
		target   = {0, 0},
		zoom     = 1,
		rotation = 0,
	}

	game := Game {
		should_update = true,
	}

	for i in 0 ..< MAX_BODIES {
		body := Body {
			pos = {
				rng.float32_range(f32(-WINDOW_WIDTH / 2), f32(WINDOW_WIDTH / 2)),
				rng.float32_range(f32(-WINDOW_HEIGHT / 2), f32(WINDOW_HEIGHT / 2)),
			},
		}
		game.bodies[i] = body
	}

	for !rl.WindowShouldClose() {
		if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
			game.should_update = !game.should_update
		}

		if game.should_update {
			update(&game)
		}
		render(&game, camera)
	}
}

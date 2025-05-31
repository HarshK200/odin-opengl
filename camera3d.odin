package main

import glsl "core:math/linalg/glsl"
import glfw "vendor:glfw"

Camera3d :: struct {
	lookAt:      glsl.mat4,
	pos:         glsl.vec3,
	front:       glsl.vec3,
	up:          glsl.vec3,
	cursorLastX: f64,
	cursorLastY: f64,
	yaw:         f64,
	pitch:       f64,
	fov:         f32,
}

// returns a new Camera3d pointer that by default is looking at the origin i.e. (0, 0, 0)
// and is positioned at (0, 0, -3)  NOTE: -3 here is in-terms of inverted z-axis
NewCamera3d :: proc() -> ^Camera3d {
	camera := new(Camera3d)

	camera.pos = glsl.vec3({0.0, 0.0, 3.0})
	camera.front = glsl.vec3({0.0, 0.0, -1.0})
	camera.up = glsl.vec3({0.0, 1.0, 0.0})
	camera.cursorLastX = 400
	camera.cursorLastY = 300
	camera.yaw = -90.0
	camera.fov = 45.0

	camera.lookAt = glsl.mat4LookAt(camera.pos, camera.pos + camera.front, camera.up)
	return camera
}

Camera3dOnUpdate :: proc(camera: ^Camera3d) {
	yaw := camera.yaw
	pitch := camera.pitch

	direction: glsl.vec3
	direction.x = cast(f32)(glsl.cos(glsl.radians(yaw)) * glsl.cos(glsl.radians(pitch)))
	direction.y = cast(f32)glsl.sin(glsl.radians(pitch))
	direction.z = cast(f32)(glsl.sin(glsl.radians(yaw)) * glsl.cos(glsl.radians(pitch)))
	camera.front = glsl.normalize(direction)

	camera.lookAt = glsl.mat4LookAt(camera.pos, camera.pos + camera.front, camera.up)
}

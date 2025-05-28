package main

import glsl "core:math/linalg/glsl"
import glfw "vendor:glfw"

Camera3d :: struct {
	lookAt: glsl.mat4,
}

// returns a new Camera3d pointer that by default is looking at the origin i.e. (0, 0, 0)
// and is positioned at (0, 0, -3)  NOTE: -3 here is in-terms of inverted z-axis
NewCamera3d :: proc() -> ^Camera3d {
	camera := new(Camera3d)
	camera.lookAt = glsl.mat4LookAt({0.0, 0.0, 3.0}, {0.0, 0.0, 0.0}, {0.0, 1.0, 0.0})
	return camera
}

Camera3dOnUpdate :: proc(camera: ^Camera3d) {
	radius := 6.0
	X := cast(f32)(glsl.sin(glfw.GetTime()) * radius)
	Z := cast(f32)(glsl.cos(glfw.GetTime()) * radius)
	camera.lookAt = glsl.mat4LookAt({X, 0.0, Z}, {0.0, 0.0, 0.0}, {0.0, 1.0, 0.0})
}

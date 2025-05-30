package main

import glsl "core:math/linalg/glsl"
import glfw "vendor:glfw"

Camera3d :: struct {
	lookAt: glsl.mat4,
	pos:    glsl.vec3,
	front:  glsl.vec3,
	up:     glsl.vec3,
}

// returns a new Camera3d pointer that by default is looking at the origin i.e. (0, 0, 0)
// and is positioned at (0, 0, -3)  NOTE: -3 here is in-terms of inverted z-axis
NewCamera3d :: proc() -> ^Camera3d {
	camera := new(Camera3d)

	camera.pos = glsl.vec3({0.0, 0.0, 3.0})
	camera.front = glsl.vec3({0.0, 0.0, -1.0})
	camera.up = glsl.vec3({0.0, 1.0, 0.0})

	camera.lookAt = glsl.mat4LookAt(camera.pos, camera.pos + camera.front, camera.up)
	return camera
}

Camera3dOnUpdate :: proc(camera: ^Camera3d) {
	camera.lookAt = glsl.mat4LookAt(camera.pos, camera.pos + camera.front, camera.up)
}

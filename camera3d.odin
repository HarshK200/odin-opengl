package main

import glsl "core:math/linalg/glsl"

Camera3D :: struct {
	lookAt: glsl.mat4,
}

NewCamera3D :: proc() -> ^Camera3D {
	camera := new(Camera3D)

	camera.lookAt = glsl.mat4LookAt({0.0, 0.0, 3.0}, {0.0, 0.0, 0.0}, {0.0, 1.0, 0.0})

	return camera
}

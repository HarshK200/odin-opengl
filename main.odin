package main

import "base:intrinsics"
import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import "vendor:glfw"

game := NewGame()

main :: proc() {
	InitGame()
	RunGame()
}

package main

import "base:intrinsics"
import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import "vendor:glfw"


Game :: struct {
	window:   ^Window,
	textures: map[string]^Texture, // array of textureId, points to texture in GPU memory
	shaders:  map[string]^Shader,
	Cubes:    map[string]^Cube,
}

NewGame :: proc() -> ^Game {
	return new(Game)
}

//initialize the game by loading all the textures and shader into GPU and creates window
InitGame :: proc(game: ^Game) {
	// initialize glfw
	if !glfw.Init() {
		fmt.println("glfw couldn't be initialized")
		intrinsics.debug_trap()
	}

	// create window & OpenGL context
	game.window = NewWindow(800, 600, "Ballz")
	glfw.MakeContextCurrent(game.window.handlerID)

	// load OpenGL bindings
	gl.load_up_to(int(4), 6, glfw.gl_set_proc_address)
	fmt.println("OpenGL version: ", gl.GetString(gl.VERSION)) // HACK: DEBUG ONLY

	// set OpenGL config
	gl.Viewport(0, 0, 800, 600)
	gl.Enable(gl.DEPTH_TEST)

	LoadAllTextures(game)

	LoadAllShaders(game)
}

//starts the main game loop
RunGame :: proc(game: ^Game) {
	windowId := game.window.handlerID

	Ready(game)
	for !glfw.WindowShouldClose(windowId) {
		Update(game)
	}
}

Ready :: proc(game: ^Game) {
	gl.UseProgram(game.shaders["basic_shader"].ProgramId)


	cubePositions: []glsl.vec3 = {
		glsl.vec3({0.0, 0.0, 0.0}),
		glsl.vec3({2.0, 5.0, -15.0}),
		glsl.vec3({-1.5, -2.2, -2.5}),
		glsl.vec3({-3.8, -2.0, -12.3}),
		glsl.vec3({2.4, -0.4, -3.5}),
		glsl.vec3({-1.7, 3.0, -7.5}),
		glsl.vec3({1.3, -2.0, -2.5}),
		glsl.vec3({1.5, 2.0, -2.5}),
		glsl.vec3({1.5, 0.2, -1.5}),
		glsl.vec3({-1.3, 1.0, -1.5}),
	}

	for cubePos, idx in cubePositions {
		if idx % 2 == 0 {
			game.Cubes[fmt.tprintf("cube%i", idx)] = NewCube(game.textures["beluga_cat"], cubePos)
		} else {
			game.Cubes[fmt.tprintf("cube%i", idx)] = NewCube(game.textures["cat2"], cubePos)
		}
	}
}

Update :: proc(game: ^Game) {
	glfw.PollEvents()

	gl.ClearColor(0.15, 0.25, 0.2, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	shaderProgramId := game.shaders["basic_shader"].ProgramId

	transformMatLoc := gl.GetUniformLocation(shaderProgramId, "transformMatrix")

	for key, cube in game.Cubes {
		model := glsl.mat4Translate(cube.pos)
		model *= glsl.mat4Rotate(
			glsl.vec3({1.0, 1.0, 0.0}),
			cast(f32)(((glfw.GetTime() + cast(f64)cube.vao) / 2)),
		)
		view := glsl.mat4Translate(glsl.vec3({0.0, 0.0, -3.0}))
		proj := glsl.mat4Perspective(45.0, 800 / 600, 0.1, 100)

		transformMat := proj * view * model
		gl.UniformMatrix4fv(transformMatLoc, 1, gl.FALSE, cast(^f32)&transformMat)

		gl.BindTexture(gl.TEXTURE_2D, cube.texture.Id)
		gl.BindVertexArray(cube.vao)
		gl.DrawArrays(gl.TRIANGLES, 0, 36)
	}

	glfw.SwapBuffers(game.window.handlerID)
}

package main

import "base:intrinsics"
import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import "vendor:glfw"


Game :: struct {
	window:    ^Window,
	textures:  map[string]^Texture, // array of textureId, points to texture in GPU memory
	shaders:   map[string]^Shader,
	Cubes:     map[string]^Cube,
	Camera3d:  ^Camera3d,
	deltaTime: f64,
	prevTime:  f64,
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

	game.Camera3d = NewCamera3d()
	game.deltaTime = 0.0
	game.prevTime = 0.0
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
	// Generate all the entities
	gl.UseProgram(game.shaders["basic_shader"].ProgramId)

	// INFO: creating all entities (for now just the cube)
	CubeOnReady(game)
}

Update :: proc(game: ^Game) {
	UpdateDeltaTime(game)
	glfw.PollEvents()
	ProcessKeyInput(game)

	gl.ClearColor(0.15, 0.25, 0.2, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	// INFO: update camera position
	Camera3dOnUpdate(game.Camera3d)

	// INFO: update all entites (for now just the cube)
	CubeOnUpdate(game)

	glfw.SwapBuffers(game.window.handlerID)
}

UpdateDeltaTime :: proc(game: ^Game) {
	currentTime := glfw.GetTime()
	game.deltaTime = currentTime - game.prevTime
	game.prevTime = currentTime
}

ProcessKeyInput :: proc(game: ^Game) {
	window := game.window.handlerID
	camera := game.Camera3d
	cameraSpeed: f32 = 2.5 * cast(f32)game.deltaTime

	// handle camera3d movement
	if glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS {
		camera.pos += cameraSpeed * camera.front
	}
	if glfw.GetKey(window, glfw.KEY_S) == glfw.PRESS {
		camera.pos -= cameraSpeed * camera.front
	}
	if glfw.GetKey(window, glfw.KEY_A) == glfw.PRESS {
		camera.pos -= cameraSpeed * (glsl.normalize(glsl.cross(camera.front, camera.up)))
	}
	if glfw.GetKey(window, glfw.KEY_D) == glfw.PRESS {
		camera.pos += cameraSpeed * (glsl.normalize(glsl.cross(camera.front, camera.up)))
	}
}

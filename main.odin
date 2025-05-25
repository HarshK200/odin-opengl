package main

import "base:intrinsics"
import "core:c"
import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import "vendor:glfw"


main :: proc() {
	// INFO: initialize glfw
	if !glfw.Init() {
		fmt.println("glfw couldn't be initialized")
		intrinsics.debug_trap()
	}

	// INFO: create window
	window := NewWindow(800, 600, "Ballz")
	glfw.MakeContextCurrent(window.handlerID)

	shaderProgram := init()

    for !glfw.WindowShouldClose(window.handlerID) {
        // INFO: handle user input
		glfw.PollEvents()

		// INFO: draw 3D cube
		draw(shaderProgram)

		glfw.SwapBuffers(window.handlerID)
	}

	glfw.DestroyWindow(window.handlerID)
	free(window)

	glfw.Terminate()
}

// load OpenGL and intialize shader program then use it
init :: proc() -> Shader {
	// INFO: load opengl bindings
	gl.load_up_to(int(4), 6, glfw.gl_set_proc_address)

    // INFO: opengl config
	fmt.println("OpenGL version: ", gl.GetString(gl.VERSION))
	gl.Viewport(0, 0, 800, 600)
    gl.Enable(gl.DEPTH_TEST)

	// INFO: creates, compiles and links a shader program then returns it
	shaderProgram := NewShader(
		"/home/harsh/Desktop/odin-opengl/assets/shaders/vertex.glsl",
		"/home/harsh/Desktop/odin-opengl/assets/shaders/fragment.glsl",
	)

	// INFO: setting buffers in gpu
	vertices := []f32 {
        -0.5, -0.5, -0.5,  0.0, 0.0,
         0.5, -0.5, -0.5,  1.0, 0.0,
         0.5,  0.5, -0.5,  1.0, 1.0,
         0.5,  0.5, -0.5,  1.0, 1.0,
        -0.5,  0.5, -0.5,  0.0, 1.0,
        -0.5, -0.5, -0.5,  0.0, 0.0,

        -0.5, -0.5,  0.5,  0.0, 0.0,
         0.5, -0.5,  0.5,  1.0, 0.0,
         0.5,  0.5,  0.5,  1.0, 1.0,
         0.5,  0.5,  0.5,  1.0, 1.0,
        -0.5,  0.5,  0.5,  0.0, 1.0,
        -0.5, -0.5,  0.5,  0.0, 0.0,

        -0.5,  0.5,  0.5,  1.0, 0.0,
        -0.5,  0.5, -0.5,  1.0, 1.0,
        -0.5, -0.5, -0.5,  0.0, 1.0,
        -0.5, -0.5, -0.5,  0.0, 1.0,
        -0.5, -0.5,  0.5,  0.0, 0.0,
        -0.5,  0.5,  0.5,  1.0, 0.0,

         0.5,  0.5,  0.5,  1.0, 0.0,
         0.5,  0.5, -0.5,  1.0, 1.0,
         0.5, -0.5, -0.5,  0.0, 1.0,
         0.5, -0.5, -0.5,  0.0, 1.0,
         0.5, -0.5,  0.5,  0.0, 0.0,
         0.5,  0.5,  0.5,  1.0, 0.0,

        -0.5, -0.5, -0.5,  0.0, 1.0,
         0.5, -0.5, -0.5,  1.0, 1.0,
         0.5, -0.5,  0.5,  1.0, 0.0,
         0.5, -0.5,  0.5,  1.0, 0.0,
        -0.5, -0.5,  0.5,  0.0, 0.0,
        -0.5, -0.5, -0.5,  0.0, 1.0,

        -0.5,  0.5, -0.5,  0.0, 1.0,
         0.5,  0.5, -0.5,  1.0, 1.0,
         0.5,  0.5,  0.5,  1.0, 0.0,
         0.5,  0.5,  0.5,  1.0, 0.0,
        -0.5,  0.5,  0.5,  0.0, 0.0,
        -0.5,  0.5, -0.5,  0.0, 1.0
	}
    // NOTE: not using this right now
    indices := []u32 {
        0
    }

	va: u32
	gl.GenVertexArrays(1, &va)
	gl.BindVertexArray(va)

	vb: u32
	gl.GenBuffers(1, &vb)
	gl.BindBuffer(gl.ARRAY_BUFFER, vb)
	gl.BufferData(gl.ARRAY_BUFFER, len(vertices) * size_of(f32), &vertices[0], gl.STATIC_DRAW)

    // INFO: position attribute pointer
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 5 * size_of(f32), cast(uintptr)0)
	gl.EnableVertexAttribArray(0)
    // INFO: texture attribute pointer
    gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 5 * size_of(f32), cast(uintptr)(3 * size_of(f32)))
	gl.EnableVertexAttribArray(1)

    ib: u32
    gl.GenBuffers(1, &ib)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ib)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices) * size_of(u32), &indices[0], gl.STATIC_DRAW)

	gl.UseProgram(shaderProgram.ProgramId)

    // INFO: loading texture
    textureID := load_texture_from_file("/home/harsh/Desktop/odin-opengl/assets/textures/beluga-cat-meme.gif")
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, textureID)

    return shaderProgram
}

// draw the currently bound buffers
draw :: proc(shaderProgram: Shader) {
	gl.ClearColor(0.15, 0.25, 0.2, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

    cubePositions :[]glsl.vec3 = {
        glsl.vec3({0.0,  0.0,  0.0}),
        glsl.vec3({2.0,  5.0, -15.0}),
        glsl.vec3({-1.5, -2.2, -2.5}),
        glsl.vec3({-3.8, -2.0, -12.3}),
        glsl.vec3({ 2.4, -0.4, -3.5}),
        glsl.vec3({-1.7,  3.0, -7.5}),
        glsl.vec3({ 1.3, -2.0, -2.5}),
        glsl.vec3({ 1.5,  2.0, -2.5}),
        glsl.vec3({ 1.5,  0.2, -1.5}),
        glsl.vec3({-1.3,  1.0, -1.5}),
    }

    transformMatLoc := gl.GetUniformLocation(shaderProgram.ProgramId, "transformMatrix")

    for pos, idx in cubePositions {
        model := glsl.mat4Translate(pos)
        model = model * glsl.mat4Rotate(glsl.vec3({1.0, 1.0, 0.0}), cast(f32)((cast(f64)idx + glfw.GetTime() / 2)))
        view := glsl.mat4Translate(glsl.vec3({0.0, 0.0, -3.0}))
        proj := glsl.mat4Perspective(45.0, 800/600, 0.1, 100)

        transformMat := proj * view * model
        gl.UniformMatrix4fv(transformMatLoc, 1, gl.FALSE, cast(^f32) &transformMat)

        gl.DrawArrays(gl.TRIANGLES, 0, 36)
    }
}

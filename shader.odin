package main

import "base:intrinsics"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"
import gl "vendor:OpenGL"

Shader :: struct {
	ProgramId: u32,
}

//loads vertex and fragmentShader from file, compiles, links and returns a pointer to the shader program
NewShader :: proc(vertexPath, fragmentPath: string) -> ^Shader {
	// INFO: reading shaders fromfile
	ok: bool
	vertexSource: []u8
	fragmentSource: []u8
	if vertexSource, ok = os.read_entire_file(vertexPath, context.temp_allocator); !ok {
		fmt.eprintln("Couldn't read vertex shader file")
		intrinsics.debug_trap()
	}
	if fragmentSource, ok = os.read_entire_file(fragmentPath, context.temp_allocator); !ok {
		fmt.eprintln("Couldn't read fragment shader file")
		intrinsics.debug_trap()
	}
	vertexCstring := strings.clone_to_cstring(cast(string)vertexSource, context.temp_allocator)
	fragmentCstring := strings.clone_to_cstring(cast(string)fragmentSource, context.temp_allocator)

	// INFO: creating shaders
	vertexShader := gl.CreateShader(gl.VERTEX_SHADER)
	fragmentShader := gl.CreateShader(gl.FRAGMENT_SHADER)
	gl.ShaderSource(vertexShader, 1, &vertexCstring, nil)
	gl.ShaderSource(fragmentShader, 1, &fragmentCstring, nil)

	// INFO: compiling shaders
	success: i32
	gl.CompileShader(vertexShader)
	gl.GetShaderiv(vertexShader, gl.COMPILE_STATUS, &success)
	if success == 0 {
		fmt.eprintln("Error compiling vertexShader")
		intrinsics.debug_trap()
	}
	gl.CompileShader(fragmentShader)
	gl.GetShaderiv(fragmentShader, gl.COMPILE_STATUS, &success)
	if success == 0 {
		fmt.eprintln("Error compiling fragmentShader")
		intrinsics.debug_trap()
	}

	// INFO: creating shader program
	programId := gl.CreateProgram()
	gl.AttachShader(programId, vertexShader)
	gl.AttachShader(programId, fragmentShader)
	gl.LinkProgram(programId)

	// INFO: clean up
	gl.DeleteShader(vertexShader)
	gl.DeleteShader(fragmentShader)


	// INFO: free used buffers
	free_all(context.temp_allocator)

	shader := new(Shader)
	shader.ProgramId = programId

	return shader
}

//loads all shaders from disk, compiles, links and adds shaderProgram handleId to providedgame
LoadAllShaders :: proc(game: ^Game) {
	// load shader from file
	basicShader := NewShader(
		"/home/harsh/Desktop/odin-opengl/assets/shaders/vertex.glsl",
		"/home/harsh/Desktop/odin-opengl/assets/shaders/fragment.glsl",
	)

	// add shaderId to game.shaders map
	game.shaders["basic_shader"] = basicShader
}

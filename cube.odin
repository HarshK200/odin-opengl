package main

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

Cube :: struct {
	texture: ^Texture,
	pos:     glsl.vec3,
	vao:     u32, // contains all the state about vertex, vertex attribute and index
}

// WARNING: DO NOT gl.DrawElements() i've not configured the indices for that right now
NewCube :: proc(texture: ^Texture, position: glsl.vec3) -> ^Cube {
	cube := new(Cube)

	vertices := []f32 {
		-0.5,
		-0.5,
		-0.5,
		0.0,
		0.0,
		0.5,
		-0.5,
		-0.5,
		1.0,
		0.0,
		0.5,
		0.5,
		-0.5,
		1.0,
		1.0,
		0.5,
		0.5,
		-0.5,
		1.0,
		1.0,
		-0.5,
		0.5,
		-0.5,
		0.0,
		1.0,
		-0.5,
		-0.5,
		-0.5,
		0.0,
		0.0,
		-0.5,
		-0.5,
		0.5,
		0.0,
		0.0,
		0.5,
		-0.5,
		0.5,
		1.0,
		0.0,
		0.5,
		0.5,
		0.5,
		1.0,
		1.0,
		0.5,
		0.5,
		0.5,
		1.0,
		1.0,
		-0.5,
		0.5,
		0.5,
		0.0,
		1.0,
		-0.5,
		-0.5,
		0.5,
		0.0,
		0.0,
		-0.5,
		0.5,
		0.5,
		1.0,
		0.0,
		-0.5,
		0.5,
		-0.5,
		1.0,
		1.0,
		-0.5,
		-0.5,
		-0.5,
		0.0,
		1.0,
		-0.5,
		-0.5,
		-0.5,
		0.0,
		1.0,
		-0.5,
		-0.5,
		0.5,
		0.0,
		0.0,
		-0.5,
		0.5,
		0.5,
		1.0,
		0.0,
		0.5,
		0.5,
		0.5,
		1.0,
		0.0,
		0.5,
		0.5,
		-0.5,
		1.0,
		1.0,
		0.5,
		-0.5,
		-0.5,
		0.0,
		1.0,
		0.5,
		-0.5,
		-0.5,
		0.0,
		1.0,
		0.5,
		-0.5,
		0.5,
		0.0,
		0.0,
		0.5,
		0.5,
		0.5,
		1.0,
		0.0,
		-0.5,
		-0.5,
		-0.5,
		0.0,
		1.0,
		0.5,
		-0.5,
		-0.5,
		1.0,
		1.0,
		0.5,
		-0.5,
		0.5,
		1.0,
		0.0,
		0.5,
		-0.5,
		0.5,
		1.0,
		0.0,
		-0.5,
		-0.5,
		0.5,
		0.0,
		0.0,
		-0.5,
		-0.5,
		-0.5,
		0.0,
		1.0,
		-0.5,
		0.5,
		-0.5,
		0.0,
		1.0,
		0.5,
		0.5,
		-0.5,
		1.0,
		1.0,
		0.5,
		0.5,
		0.5,
		1.0,
		0.0,
		0.5,
		0.5,
		0.5,
		1.0,
		0.0,
		-0.5,
		0.5,
		0.5,
		0.0,
		0.0,
		-0.5,
		0.5,
		-0.5,
		0.0,
		1.0,
	}

	// WARNING: not in use
	indices := []u32 {
		0,
		1,
		2,
		2,
		3,
		1, // quad 1
	}

	// vertex array
	va: u32
	gl.GenVertexArrays(1, &va)
	gl.BindVertexArray(va)

	// vertex array buffer
	vb: u32
	gl.GenBuffers(1, &vb)
	gl.BindBuffer(gl.ARRAY_BUFFER, vb)
	gl.BufferData(gl.ARRAY_BUFFER, len(vertices) * size_of(f32), &vertices[0], gl.STATIC_DRAW)

	// index buffer
	ib: u32
	gl.GenBuffers(1, &ib)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ib)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(indices) * size_of(u32),
		&indices[0],
		gl.STATIC_DRAW,
	)

	// attribute pointer config
	// position attribute
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 5 * size_of(f32), cast(uintptr)0)
	gl.EnableVertexAttribArray(0)
	// texture attribute
	gl.VertexAttribPointer(
		1,
		2,
		gl.FLOAT,
		gl.FALSE,
		5 * size_of(f32),
		cast(uintptr)(3 * size_of(f32)),
	)
	gl.EnableVertexAttribArray(1)

	// unbinding vertex array
	gl.BindVertexArray(0)

	cube.texture = texture
	cube.pos = position
	cube.vao = va

	return cube
}

CubeOnReady :: proc() {
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

CubeOnUpdate :: proc() {
	shaderProgramId := game.shaders["basic_shader"].ProgramId
	transformMatLoc := gl.GetUniformLocation(shaderProgramId, "transformMatrix")
	for key, cube in game.Cubes {
		fov := glsl.radians(game.Camera3d.fov)

		model := glsl.mat4Translate(cube.pos)
		model *= glsl.mat4Rotate(
			glsl.vec3({1.0, 1.0, 0.0}),
			cast(f32)(((glfw.GetTime() + cast(f64)cube.vao) / 2)),
		)
		view := game.Camera3d.lookAt
		proj := glsl.mat4Perspective(fov, 800 / 600, 0.1, 100)

		transformMat := proj * view * model
		gl.UniformMatrix4fv(transformMatLoc, 1, gl.FALSE, cast(^f32)&transformMat)

		gl.BindTexture(gl.TEXTURE_2D, cube.texture.Id)
		gl.BindVertexArray(cube.vao)
		gl.DrawArrays(gl.TRIANGLES, 0, 36)
	}
}

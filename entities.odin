package main

import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

Player :: struct {
	texture: ^Texture,
}

Cube :: struct {
    texture: ^Texture,
    pos:     glsl.vec3,
    vao:     u32, // contains all the state about vertex, vertex attribute and index
}

// WARNING: DO NOT gl.DrawElements() i've this is not configured for that right now
NewCube :: proc(texture: ^Texture, position: glsl.vec3) -> ^Cube {
    cube := new(Cube)

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

	indices := []u32 {
		0, 1, 2, 2, 3, 1, // quad 1
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

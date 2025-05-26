package main

import "base:intrinsics"
import "core:fmt"
import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

Texture :: struct {
	Id: u32,
}

//loads the texture from file and stores it in the gpu memory
LoadTextureFromFile :: proc(filePath: cstring) -> ^Texture {
	// loading image from file
	width, height, nrChannels: i32
	stbi.set_flip_vertically_on_load(1)
	data := stbi.load(filePath, &width, &height, &nrChannels, 0)
	if (data == nil) {
		fmt.eprintln("Error loading texture file")
		intrinsics.debug_trap()
	}
	fmt.println("Image channel: ", nrChannels)
	fmt.println("Data ptr: ", uintptr(data))
	image_format: u32
	switch nrChannels {
	case 3:
		image_format = gl.RGB
	case 4:
		image_format = gl.RGBA
	case:
		image_format = 3
	}

	// creating new texture
	texture := new(Texture)
	gl.GenTextures(1, &texture.Id)
	gl.BindTexture(gl.TEXTURE_2D, texture.Id)

	// setting texture parameters
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT) // set texture wrap to repeat
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	// setting texture data
	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		cast(i32)image_format,
		width,
		height,
		0,
		image_format,
		gl.UNSIGNED_BYTE,
		cast(rawptr)data,
	)
	gl.GenerateMipmap(gl.TEXTURE_2D)

    // unbinding the texture
    gl.BindTexture(gl.TEXTURE_2D, 0)

	// cleanup
	stbi.image_free(data)

	return texture
}


// loads all texture in GPU memory and adds there handleId to provided game object
LoadAllTextures :: proc(game: ^Game) {
    game.textures["beluga_cat"] = LoadTextureFromFile("/home/harsh/Desktop/odin-opengl/assets/textures/beluga-cat-meme.gif")
    game.textures["cat2"] = LoadTextureFromFile("/home/harsh/Desktop/odin-opengl/assets/textures/cat2.jpg")
}

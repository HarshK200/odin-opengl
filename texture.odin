package main

import "base:intrinsics"
import "core:fmt"
import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

load_texture_from_file :: proc(filePath: cstring) -> u32 {
	// INFO: loading image from file
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

	textureID: u32
	gl.GenTextures(1, &textureID)
	gl.BindTexture(gl.TEXTURE_2D, textureID)

	// INFO: setting texture parameters
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT) // set texture wrap to repeat
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

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

	stbi.image_free(data)

	return textureID
}

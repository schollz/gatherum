package main

import (
	"encoding/base64"
	"fmt"
	"image/png"
	"strings"
)

func main() {
	var b64 string
	b64 = "iVBORw0KGgoAAAANSUhEUgAAAIAAAAATCAYAAABYzAUmAAAAf0lEQVRoge3X0RWAMAhD0e6/dF2goFJ+Qt49xwkSqKwFRfvnhyEqgVKAAbLg3wJmGwzQFRwFENX1vrMNBrkNkAII6wiPAog6rW+uAxNR8JUrgf8AQVngpzAJ2URUDMI3EIXO9Jv48hTACAUwl10FlMMEF4GpbPIpgAEm31gp5AcMN1epFTplLwAAAABJRU5ErkJggg=="
	b64 = "iVBORw0KGgoAAAANSUhEUgAAAIAAAAASCAYAAACTkNaDAAAAiUlEQVRoge3ZQQ6AIAxEUe5/6boltS3FndP/EqNxOwMIroU/s8YFQd1wbbtTCCFVkOae9+ApgIjb6T6aCSiDmFMBfOgUQMTNaGY5EPMlRJYBIZ3vgOwd4YvywWZBUwJh3bWeAghiZA/n9/wYjAIMV+0MKMcQ0f8Awh8iCpvwh6j2/xCXnQy+Tg0fY8FZp8ypXMcAAAAASUVORK5CYII="
	img, err := png.Decode(base64.NewDecoder(base64.StdEncoding, strings.NewReader(b64)))
	if err != nil {
		panic(err)
	}
	for y := img.Bounds().Min.Y; y < img.Bounds().Max.Y; y++ {
		for x := img.Bounds().Min.X; x < img.Bounds().Max.X; x++ {
			c := img.At(x, y)
			_, _, _, d := c.RGBA()
			if d > 0 {
				fmt.Printf("{%d,%d},", x+3, y)
			}
		}
	}
}

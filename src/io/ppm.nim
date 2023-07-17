#[
    http://paulbourke.net/dataformats/ppm/
]#
import math
import strformat

import ../vec3
import ../film


proc saveImagePPM*(fileName: string, film: Film, samplesPerPixel: int) =
    var
        outputFile : File = open(fileName, FileMode.fmWrite)
        pixelColor: Color

        scale: float64 = 1.0 / float64(samplesPerPixel)
        r: float64
        g: float64
        b: float64

    write(outputFile, fmt"P3{'\n'}{film.width} {film.height}{'\n'}255{'\n'}")

    for h in countdown(film.height-1, 0):
        for w in 0..<film.width:
            pixelColor = film.pixelMap[film.width*h+w]
            r = sqrt(pixelColor.r()*scale)
            g = sqrt(pixelColor.g()*scale)
            b = sqrt(pixelColor.b()*scale)

            outputFile.write(fmt"{int(clamp(r, 0.0, 0.999)*255.999)} ")
            outputFile.write(fmt"{int(clamp(g, 0.0, 0.999)*255.999)} ")
            outputFile.write(fmt"{int(clamp(b, 0.0, 0.999)*255.999)}{'\n'}")

    outputFile.close()

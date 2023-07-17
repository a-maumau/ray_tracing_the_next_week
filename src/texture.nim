import math
import strformat

import pixie

import vec3
import perlin
import misc

# to erase "method has lock level <unknown>, but another method has 0"
# warnings
{.warning[LockLevel]:off.}


type Texture* = ref object of RootObj
    colorValue: vec3.Color

method value*(this: Texture, u: float64, v: float64, p: Point3): vec3.Color {.base.} =
    raiseAssert("you need impl. this function.")

type SolidColor* = ref object of Texture

proc newSolidColor*(c: vec3.Color): SolidColor =
    return SolidColor(colorValue: c)

proc newSolidColor*(r: float64, g: float64, b:float64): SolidColor =
    return SolidColor(colorValue: newColor(r, g, b))

method value*(this: SolidColor, u: float64, v: float64, p: Point3): vec3.Color =
    return this.colorValue

type CheckerTexture* = ref object of Texture
    odd: Texture
    even: Texture

proc newCheckerTexture*(color1: vec3.Color, color2: vec3.Color): CheckerTexture =
    return CheckerTexture(even: newSolidColor(color1), odd: newSolidColor(color2))

proc newCheckerTexture*(even: Texture, odd: Texture): CheckerTexture =
    return CheckerTexture(even: even, odd: odd)

method value*(this: CheckerTexture, u: float64, v: float64, p: Point3): vec3.Color =
    let sines = sin(10*p.x())*sin(10*p.y())*sin(10*p.z())
    if sines < 0:
        return this.odd.value(u, v, p)
    else:
        return this.even.value(u, v, p)

type NoiseTexture* = ref object of Texture
    noise: Perlin
    scale: float64

proc newNoiseTexture*(sc: float64 = 1.0): NoiseTexture =
    return NoiseTexture(
        noise: newPerlin(),
        scale: sc
    )

method value*(this: NoiseTexture, u: float64, v: float64, p: Point3): vec3.Color =
    return newColor(1, 1, 1)*0.5*(1.0+sin(this.scale*p.z()+10.0*this.noise.turb(p)))

type ImageTexture* = ref object of Texture
    data: Image
    width, height: int
    repeatNumU, repeatNumV: int
    #bytesPerScanline: int

proc newImageTexture*(fileName: string, repeatNumU: int = 1, repeatNumV: int = 1): ImageTexture =
    var img: Image

    try:
        img = readImage(fileName)
    except CatchableError:
        echo(fmt"cannot open {fileName}")
        # If we have no texture data, then return cyan texture as a debugging aid
        img = newImage(256, 256)
        img.fill(rgba(0, 255, 255, 255)) # cyan

    return ImageTexture(
        data: img,
        width: img.width,
        height: img.height,
        repeatNumU: repeatNumU,
        repeatNumV: repeatNumV
    )

method value*(this: ImageTexture, u: float64, v: float64, p: Point3): vec3.Color =
    let
        clampU: float64 = clamp(u, 0.0, 1.0)
        clampV: float64 = 1.0 - clamp(v, 0.0, 1.0)

    var
        # Clamp input texture coordinates to [0,1] x [1,0]
        i: int = int(clampU*float(this.width*this.repeatNumU)) mod this.width
        j: int = int(clampV*float(this.height*this.repeatNumV)) mod this.height

    #if i >= this.width:
    #    i = this.width-1

    #if j >= this.height:
    #    j = this.height-1

    let colorScale: float64 = 1.0/255.0

    return newColor(
        colorScale*float(this.data[i, j].r),
        colorScale*float(this.data[i, j].g),
        colorScale*float(this.data[i, j].b)
    )

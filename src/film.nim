import vec3


type Film* = ref object of RootObj    
    width*: int
    height*: int
    aspectRatio*: float64

    pixelMap*: seq[Color]

proc newFilm*(width: int, height: int): Film =
    var pixels = newSeq[Color](width*height)

    for i in 0..<width*height:
        pixels[i] = newColor(0, 0, 0)

    return Film(
        width: width,
        height: height,
        aspectRatio: float(width)/float(height),
        pixelMap: pixels
    )

proc clear*(this: Film) =
    for i in 0..<this.height*this.width:
        this.pixelMap[i].setToZero()

proc `[]`*(this: Film, i: SomeInteger): Color =
    return this.pixelMap[i]

proc `[]=`*(this: Film, i: SomeInteger, c: Color) =
    this.pixelMap[i] = c

proc setColor*(this: Film, x: Natural, y: Natural, c: Color) =
    this.pixelMap[this.width*y+x] = c

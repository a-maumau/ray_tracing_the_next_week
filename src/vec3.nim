import math
import strformat

import rand


let
    VEC_SMALL_VAL = 1e-8

type Vec3* = ref object of RootObj
    e*: array[3, float64]

proc newVec3*(e1: float64 = 0.0, e2: float64 = 0.0, e3: float64 = 0.0): Vec3 =
    return Vec3(e: [e1, e2, e3])

# SomeInteger contains sign/unsign int type
proc `[]`*(v: Vec3, i: SomeInteger): float64 =
    return v.e[i]

proc `[]=`*(v: var Vec3, i: SomeInteger, c: SomeNumber) =
    v.e[i] = float64(c)

# in the original implement for +=, *=, and so on,
# it will always create a new vector
# SomeNumber contains all number type
proc `+=`*(v: var Vec3, c: SomeNumber) =
    v.e[0] += c
    v.e[1] += c
    v.e[2] += c

proc `+=`*(v1: var Vec3, v2: Vec3) =
    v1.e[0] += v2.e[0]
    v1.e[1] += v2.e[1]
    v1.e[2] += v2.e[2]

proc `*=`*(v: var Vec3, c: SomeNumber) =
    v.e[0] *= c
    v.e[1] *= c
    v.e[2] *= c

proc `/=`*(v: var Vec3, c: SomeNumber) =
    v.e[0] /= c
    v.e[1] /= c
    v.e[2] /= c

proc `-`*(v: Vec3): Vec3 =
    return newVec3(-v.e[0], -v.e[1], -v.e[2])

proc `+`*(v1: Vec3, v2: Vec3): Vec3 =
    return newVec3(v1.e[0]+v2.e[0], v1.e[1]+v2.e[1], v1.e[2]+v2.e[2])

proc `-`*(v1: Vec3, v2: Vec3): Vec3 =
    return newVec3(v1.e[0]-v2.e[0], v1.e[1]-v2.e[1], v1.e[2]-v2.e[2])

proc `*`*(v1: Vec3, v2: Vec3): Vec3 =
    return newVec3(v1.e[0]*v2.e[0], v1.e[1]*v2.e[1], v1.e[2]*v2.e[2])

proc `*`*(c: SomeNumber, v: Vec3): Vec3 =
    return newVec3(v.e[0]*c, v.e[1]*c, v.e[2]*c)

proc `*`*(v: Vec3, c: SomeNumber): Vec3 =
    return c*v

proc `/`*(v: Vec3, c: SomeNumber): Vec3 =
    #return newVec3(v.e1/c, v.e2/c, v.e3/c)
    return (1/c)*v

proc `$`*(v: Vec3): string =
    return fmt"({v.e[0]}, {v.e[1]}, {v.e[2]})"

proc copy*(v: Vec3): Vec3 =
    return newVec3(v.e[0], v.e[1], v.e[2])

proc dot*(v1: Vec3, v2: Vec3): float64 =
    return v1.e[0]*v2.e[0] + v1.e[1]*v2.e[1] + v1.e[2]*v2.e[2]

proc cross*(v1: Vec3, v2: Vec3): Vec3 =
    return newVec3(
        v1.e[1] * v2.e[2] - v1.e[2] * v2.e[1],
        v1.e[2] * v2.e[0] - v1.e[0] * v2.e[2],
        v1.e[0] * v2.e[1] - v1.e[1] * v2.e[0]
    )

proc lengthSquared*(v: Vec3): float64 =
    return v.e[0]*v.e[0] + v.e[1]*v.e[1] + v.e[2]*v.e[2]

proc length*(v: Vec3): float64 =
    return sqrt(lengthSquared(v))

proc unitVector*(v: Vec3): Vec3 =
    return v / v.length()

proc random*(): Vec3 =
    return newVec3(rand(), rand(), rand())

proc random*(minVal: float64, maxVal: float64): Vec3 =
    return newVec3(rand(minVal, maxVal), rand(minVal, maxVal), rand(minVal, maxVal))

proc randomInUnitSphere*(): Vec3 =
    var p: Vec3

    while true:
        p = random(-1, 1)
        
        if p.lengthSquared() >= 1:
            continue
        else:
            return p

proc randomUnitVector*(): Vec3 = 
    return unitVector(randomInUnitSphere())

proc randomInHemisphere*(normal: Vec3): Vec3 =
    var inUnitSphere: Vec3 = randomInUnitSphere()

    # in the same hemisphere as the normal
    if dot(inUnitSphere, normal) > 0.0:
        return inUnitSphere
    else:
        return -inUnitSphere

proc nearZero*(v: Vec3): bool =
    # return true if the vector is close to zero in all dimensions.
    return (abs(v.e[0]) < VEC_SMALL_VAL) and (abs(v.e[1]) < VEC_SMALL_VAL) and (abs(v.e[2]) < VEC_SMALL_VAL)
    
proc reflect*(v: Vec3, n: Vec3): Vec3 =
    return v - 2*dot(v, n)*n

proc refract*(v: Vec3, n: Vec3, etaiOverEtat: float64): Vec3 =
    # v should be a normal vector
    var
        cosTheta = min(dot(-v, n), 1.0)
        rOutPerp: Vec3 = etaiOverEtat * (v + cosTheta*n)
        rOutParallel: Vec3 = -sqrt(abs(1.0 - rOutPerp.lengthSquared())) * n

    return rOutPerp + rOutParallel

proc randomInUnitDisk*(): Vec3 =
    var p: Vec3

    while true:
        p = newVec3(rand(-1,1), rand(-1,1), 0);
        
        if (p.lengthSquared() >= 1):
            continue

        return p

###############################################################################
type
    Point3* = Vec3
    Color* = Vec3

proc setToZero*(v: var Vec3) =
    v.e[0] = 0
    v.e[1] = 0
    v.e[2] = 0

proc newPoint3*(e1: float64 = 0.0, e2: float64 = 0.0, e3: float64 = 0.0): Point3 =
    return Point3(e: [e1, e2, e3])

proc newColor*(e1: float64 = 0.0, e2: float64 = 0.0, e3: float64 = 0.0): Color =
    return Color(e: [e1, e2, e3])

proc setTo*(c1: var Color, c2: Color) =
    c1.e[0] = c2.e[0]
    c1.e[1] = c2.e[1]
    c1.e[2] = c2.e[2]

proc x*(p: Point3): float64 =
    return p.e[0]

proc y*(p: Point3): float64 =
    return p.e[1]

proc z*(p: Point3): float64 =
    return p.e[2]

proc r*(c: Color): float64 =
    return c.e[0]

proc g*(c: Color): float64 =
    return c.e[1]

proc b*(c: Color): float64 =
    return c.e[2]

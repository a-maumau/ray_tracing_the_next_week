import math

import vec3
import rand


let pointCount: int = 256

proc perlinGeneratePerm(): seq[int]
#proc trilinearInterp(c: array[2, array[2, array[2, float64]]], u, v, w: float64): float64
proc perlinInterp(c: array[2, array[2, array[2, Vec3]]], u: float64, v: float64, w: float64): float64

type Perlin* = ref object of RootObj
    ranfloat: seq[float64]

    ranvec: seq[Vec3]
    permX, permY, permZ: seq[int]

proc newPerlin*(): Perlin =
    var ranvec: seq[Vec3] = newSeq[Vec3](pointCount)

    for i in 0..<pointCount:
        ranvec[i] = unitVector(random(-1.0, 1.0))

    return Perlin(
        ranvec: ranvec,
        permX: perlinGeneratePerm(),
        permY: perlinGeneratePerm(),
        permZ: perlinGeneratePerm(),
    )

proc noise*(this: Perlin, p: Point3): float64 =
    let
        i: int = int(floor(p.x()))
        j: int = int(floor(p.y()))
        k: int = int(floor(p.z()))

    var
        u: float64 = p.x() - floor(p.x())
        v: float64 = p.y() - floor(p.y())
        w: float64 = p.z() - floor(p.z())
        #c: array[2, array[2, array[2, float64]]]
        c: array[2, array[2, array[2, Vec3]]]

    for di in 0..<2:
        for dj in 0..<2:
            for dk in 0..<2:
                c[di][dj][dk] = this.ranvec[
                    this.permX[(i+di) and 255] xor this.permY[(j+dj) and 255] xor this.permZ[(k+dk) and 255]
                ]

    return perlinInterp(c, u, v, w)

proc turb*(this: Perlin, p: Point3, depth: int = 7): float64 =
    var
        accum: float64 = 0.0
        tempP: Point3 = p
        weight: float64 = 1.0

    for i in 0..<depth:
        accum += weight*this.noise(tempP)
        weight *= 0.5
        tempP = tempP*2.0

    return abs(accum)

proc permute(p: var seq[int], n: int) =
    for i in countdown(n-1, 1):
        let
            target: int = randInt(0, i)
            tmp: int = p[i]

        p[i] = p[target]
        p[target] = tmp

proc perlinGeneratePerm(): seq[int] =
    var p: seq[int] = newSeq[int](pointCount)

    for i in 0..<pointCount:
        p[i] = i

    permute(p, pointCount)

    return p

#proc trilinearInterp(c: array[2, array[2, array[2, float64]]], u: float64, v: float64, w: float64): float64 =
#    var accum: float64 = 0.0
#
#    for i in 0..<2:
#        for j in 0..<2:
#            for k in 0..<2:
#                accum += (float(i)*u + float(1-i)*(1.0-u))*(float(j)*v + float(1-j)*(1.0-v))*(float(k)*w + float(1-k)*(1.0-w))*c[i][j][k]
#
#    return accum

proc perlinInterp(c: array[2, array[2, array[2, Vec3]]], u: float64, v: float64, w: float64): float64 =
    var
        # Hermite cubic to round off the interpolation
        uu: float64 = u*u*(3.0-2.0*u)
        vv: float64 = v*v*(3.0-2.0*v)
        ww: float64 = w*w*(3.0-2.0*w)
        accum: float64 = 0.0

    for i in 0..<2:
        for j in 0..<2:
            for k in 0..<2:
                var weightV: Vec3 = newVec3(u-float64(i), v-float64(j), w-float64(k))
                accum += (
                    (float64(i)*uu + float64(1-i)*(1.0-uu))*
                    (float64(j)*vv + float64(1-j)*(1.0-vv))*
                    (float64(k)*ww + float64(1-k)*(1.0-ww))*
                    c[i][j][k].dot(weightV)
                )

    return accum

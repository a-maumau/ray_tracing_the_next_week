import math

import vec3
import aabb
import renderable_object, material
import ray
import misc


type Translate* = ref object of Hittable
    obj: Hittable
    offset: Vec3

proc newTranslate*(obj: Hittable, displacement: Vec3): Translate =
    return Translate(
        obj: obj,
        offset: displacement
    )

method hit*(this: Translate, r: Ray, tMin: float64, tMax: float64, rec: var HitRecord): bool =
    var
        movedR: Ray = newRay(r.origin()-this.offset, r.direction(), r.time())

    if not this.obj.hit(movedR, tMin, tMax, rec):
        return false

    rec.p = rec.p+this.offset
    rec.setFaceNormal(movedR, rec.normal)

    return true

method boundingBox*(this: Translate, time0: float64, time1: float64, outputBox: var AABB): bool =
    if not this.obj.boundingBox(time0, time1, outputBox):
        return false

    outputBox = newAABB(
        outputBox.min() + this.offset,
        outputBox.max() + this.offset
    )

    return true

type RotateY* = ref object of Hittable
    obj: Hittable
    sinTheta, cosTheta: float64
    hasBox: bool
    bbox: AABB

proc newRotateY*(obj: Hittable, angle: float64): RotateY =
    let radians = degreesToRadians(angle)
    
    var
        pMin = newPoint3(Inf, Inf, Inf)
        pMax = newPoint3(-Inf, -Inf, -Inf)
        sinTheta: float64 = sin(radians)
        cosTheta: float64 = cos(radians)
        bbox: AABB
        hasBox: bool = obj.boundingBox(0.0, 1.0, bbox)

    for i in 0..<2:
        for j in 0..<2:
            for k in 0..<2:
                let
                    x: float64 = float64(i)*bbox.max().x + float64(1-i)*bbox.min().x()
                    y: float64 = float64(j)*bbox.max().y + float64(1-j)*bbox.min().y()
                    z: float64 = float64(k)*bbox.max().z + float64(1-k)*bbox.min().z()

                    newX = cosTheta*x + sinTheta*z
                    newZ = -sinTheta*x + cosTheta*z

                    tester = newVec3(newX, y, newZ)

                for c in 0..<3:
                    pMin[c] = min(pMin[c], tester[c])
                    pMax[c] = max(pMax[c], tester[c])

    return RotateY(
        obj: obj,
        sinTheta: sinTheta,
        cosTheta: cosTheta,
        hasBox: hasBox,
        bbox: newAABB(pMin, pMax)
    )

method hit*(this: RotateY, r: Ray, tMin: float64, tMax: float64, rec: var HitRecord): bool =
    var
        origin: Vec3 = r.origin().copy()
        direction: Vec3 = r.direction().copy()

    origin[0] = this.cosTheta*r.origin()[0] - this.sinTheta*r.origin()[2]
    origin[2] = this.sinTheta*r.origin()[0] + this.cosTheta*r.origin()[2]

    direction[0] = this.cosTheta*r.direction()[0] - this.sinTheta*r.direction()[2]
    direction[2] = this.sinTheta*r.direction()[0] + this.cosTheta*r.direction()[2]

    var
        rotatedR: Ray = newRay(origin, direction, r.time())

    if not this.obj.hit(rotatedR, tMin, tMax, rec):
        return false

    var
        p: Vec3 = rec.p.copy()
        normal: Vec3 = rec.normal.copy()

    p[0] = this.cosTheta*rec.p[0] + this.sinTheta*rec.p[2]
    p[2] = -this.sinTheta*rec.p[0] + this.cosTheta*rec.p[2]

    normal[0] = this.cosTheta*rec.normal[0] + this.sinTheta*rec.normal[2]
    normal[2] = -this.sinTheta*rec.normal[0] + this.cosTheta*rec.normal[2]

    rec.p = p
    rec.setFaceNormal(rotatedR, normal)

    return true

method boundingBox*(this: RotateY, time0: float64, time1: float64, outputBox: var AABB): bool =
    outputBox = this.bbox

    return this.hasBox

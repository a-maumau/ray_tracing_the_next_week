import vec3
import aabb
import renderable_object, material
import ray


type PlaneXY* = ref object of Hittable
    x0, x1, y0, y1: float64
    k: float64
    mat: Material

proc newPlaneXY*(x0, x1, y0, y1: float64, k: float64, mat: Material): PlaneXY =
    return PlaneXY(
        x0: x0,
        x1: x1,
        y0: y0,
        y1: y1,
        k: k,
        mat: mat
    )

method hit*(this: PlaneXY, r: Ray, tMin: float64, tMax: float64, rec: var HitRecord): bool =
    var
        t: float = (this.k - r.origin().z())/r.direction().z()

    if t < tMin or t > tMax:
        return false

    var
        x: float64 = r.origin().x() + t*r.direction().x()
        y: float64 = r.origin().y() + t*r.direction().y()

    if x < this.x0 or x > this.x1 or y < this.y0 or y > this.y1:
        return false

    rec.u = (x-this.x0)/(this.x1-this.x0)
    rec.v = (y-this.y0)/(this.y1-this.y0)
    rec.t = t

    let outwardNormal: Vec3 = newVec3(0, 0, -1)
    rec.setFaceNormal(r, outwardNormal)
    rec.mat = this.mat
    rec.p = r.at(t)

    return true

method boundingBox*(this: PlaneXY, time0: float64, time1: float64, outputBox: var AABB): bool =
    outputBox = newAABB(
        newPoint3(this.x0, this.y0, this.k-0.0001),
        newPoint3(this.x1, this.y1, this.k+0.0001)
    )

    return true

type PlaneXZ* = ref object of Hittable
    x0, x1, z0, z1: float64
    k: float64
    mat: Material

proc newPlaneXZ*(x0, x1, z0, z1: float64, k: float64, mat: Material): PlaneXZ =
    return PlaneXZ(
        x0: x0,
        x1: x1,
        z0: z0,
        z1: z1,
        k: k,
        mat: mat
    )

method hit*(this: PlaneXZ, r: Ray, tMin: float64, tMax: float64, rec: var HitRecord): bool =
    var
        t: float = (this.k - r.origin().y())/r.direction().y()

    if t < tMin or t > tMax:
        return false

    var
        x: float64 = r.origin().x() + t*r.direction().x()
        z: float64 = r.origin().z() + t*r.direction().z()

    if x < this.x0 or x > this.x1 or z < this.z0 or z > this.z1:
        return false

    rec.u = (x-this.x0)/(this.x1-this.x0)
    rec.v = (z-this.z0)/(this.z1-this.z0)
    rec.t = t

    let outwardNormal: Vec3 = newVec3(0, 1, 0)
    rec.setFaceNormal(r, outwardNormal)
    rec.mat = this.mat
    rec.p = r.at(t)

    return true

method boundingBox*(this: PlaneXZ, time0: float64, time1: float64, outputBox: var AABB): bool =
    outputBox = newAABB(
        newPoint3(this.x0, this.k-0.0001, this.z0),
        newPoint3(this.x1, this.k+0.0001, this.z1)
    )

    return true

type PlaneYZ* = ref object of Hittable
    y0, y1, z0, z1: float64
    k: float64
    mat: Material

proc newPlaneYZ*(y0, y1, z0, z1: float64, k: float64, mat: Material): PlaneYZ =
    return PlaneYZ(
        y0: y0,
        y1: y1,
        z0: z0,
        z1: z1,
        k: k,
        mat: mat
    )

method hit*(this: PlaneYZ, r: Ray, tMin: float64, tMax: float64, rec: var HitRecord): bool =
    var
        t: float = (this.k - r.origin().x())/r.direction().x()

    if t < tMin or t > tMax:
        return false

    var
        y: float64 = r.origin().y() + t*r.direction().y()
        z: float64 = r.origin().z() + t*r.direction().z()

    if y < this.y0 or y > this.y1 or z < this.z0 or z > this.z1:
        return false

    rec.u = (y-this.y0)/(this.y1-this.y0)
    rec.v = (z-this.z0)/(this.z1-this.z0)
    rec.t = t

    let outwardNormal: Vec3 = newVec3(1, 0, 0)
    rec.setFaceNormal(r, outwardNormal)
    rec.mat = this.mat
    rec.p = r.at(t)

    return true

method boundingBox*(this: PlaneYZ, time0: float64, time1: float64, outputBox: var AABB): bool =
    outputBox = newAABB(
        newPoint3(this.k-0.0001, this.y0, this.z0),
        newPoint3(this.k+0.0001, this.y1, this.z1)
    )

    return true

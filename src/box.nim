import vec3
import aabb
import renderable_object, hittable_list, material
import plane
import ray


type Box* = ref object of Hittable
    boxMin, boxMax: Point3
    sides: HittableList

proc newBox*(p0: Point3, p1: Point3, mat: Material): Box =
    var s: HittableList = newHittableList()

    s.add(newPlaneXY(p0.x(), p1.x(), p0.y(), p1.y(), p1.z(), mat))
    s.add(newPlaneXY(p0.x(), p1.x(), p0.y(), p1.y(), p0.z(), mat))

    s.add(newPlaneXZ(p0.x(), p1.x(), p0.z(), p1.z(), p1.y(), mat))
    s.add(newPlaneXZ(p0.x(), p1.x(), p0.z(), p1.z(), p0.y(), mat))

    s.add(newPlaneYZ(p0.y(), p1.y(), p0.z(), p1.z(), p1.x(), mat))
    s.add(newPlaneYZ(p0.y(), p1.y(), p0.z(), p1.z(), p0.x(), mat))

    return Box(boxMin: p0, boxMax: p1, sides: s)

method hit*(this: Box, r: Ray, tMin: float64, tMax: float64, rec: var HitRecord): bool =
    return this.sides.hit(r, tMin, tMax, rec)

method boundingBox*(this: Box, time0: float64, time1: float64, outputBox: var AABB): bool =
    outputBox = newAABB(this.boxMin, this.boxMax)

    return true

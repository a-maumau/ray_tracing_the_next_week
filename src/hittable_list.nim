import vec3
import aabb
import renderable_object, material
import ray


type HittableList* = ref object of Hittable
    renderObjects*: seq[Hittable]

proc newHittableList*(objs: seq[Hittable] = @[], initSize: int = 32): HittableList =
    return HittableList(renderObjects: objs)

proc len*(this: HittableList): int =
    return len(this.renderObjects)

proc add*(this: HittableList, obj: Hittable) =
    this.renderObjects.add(obj)

proc clear*(this: HittableList) = 
    this.renderObjects.setLen(0)

method hit*(this: HittableList, r: Ray, tMin: float64, tMax: float64, rec: var HitRecord): bool =
    var
        tempRec: HitRecord = newHitRecord(newPoint3(0, 0, 0), newVec3(0, 0, 0), 0.0)
        hitAnything: bool = false
        closestSoFar: float64 = tMax

    for obj in this.renderObjects:
        if obj.hit(r, tMin, closestSoFar, tempRec):
            hitAnything = true
            closestSoFar = tempRec.t
            rec = tempRec

    return hitAnything

method boundingBox*(this: HittableList, time0: float64, time1: float64, outputBox: var AABB): bool =
    if len(this.renderObjects) == 0:
        return false

    var
        tempBox: AABB
        firstBox: bool = true

    for obj in this.renderObjects:
        if not obj.boundingBox(time0, time1, tempBox):
            return false

        outputBox = if firstBox: tempBox else: surroundingBox(outputBox, tempBox)
        firstBox = false

    return true

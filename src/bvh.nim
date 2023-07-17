import std/algorithm

import vec3
import rand
import aabb
import hittable_list, renderable_object, material
import ray


type BVHNode* = ref object of Hittable
    left, right: Hittable
    box: AABB

proc boxCompare(a: Hittable, b: Hittable, axis: int): int =
    # comparing proc in nim's sort must be in int

    var
        boxA, boxB: AABB

    if not a.boundingBox(0, 0, boxA) or not b.boundingBox(0, 0, boxB):
        echo "No bounding box in bvh_node constructor."

    if boxA.min()[axis] < boxB.min()[axis]:
        return 1
    else:
        return -1

proc boxXCompare(a: Hittable, b: Hittable): int =
    return boxCompare(a, b, 0)

proc boxYCompare(a: Hittable, b: Hittable): int =
    return boxCompare(a, b, 1)

proc boxZCompare(a: Hittable, b: Hittable): int =
    return boxCompare(a, b, 2)

# `end` is a keyword in nim
proc buildBVH(objects: var seq[Hittable], start: int, tail: int, time0: float64, time1: float64): BVHNode =
    ## this proc will create the BVH tree and returns the top node

    var
        left, right: Hittable
        box: AABB

        boxLeft, boxRight: AABB

        axis = randInt(0, 2)
        comparator: proc = if axis == 0: boxXCompare elif axis == 1: boxYCompare else: boxZCompare
        objectSpan: int = tail-start

    if objectSpan == 1:
        left = objects[start]
        right = objects[start]
    elif objectSpan == 2:
        if comparator(objects[start], objects[start+1]) == 1:
            left = objects[start]
            right = objects[start+1]
        else:
            left = objects[start+1]
            right = objects[start]
    else:        
        var sortedObjects = sorted(objects[start..<tail], comparator)

        let mid: int = int(objectSpan/2)
        right = buildBVH(sortedObjects, 0, mid, time0, time1)
        left = buildBVH(sortedObjects, mid, objectSpan, time0, time1)

    if not left.boundingBox(time0, time1, boxLeft) or not right.boundingBox(time0, time1, boxRight):
        echo "No bounding box in bvh_node constructor."

    box = surroundingBox(boxLeft, boxRight)

    return BVHNode(left: left, right: right, box: box)

proc newBVHNode*(list: HittableList, time0: float64, time1: float64): BVHNode =
    return buildBVH(
        objects=list.renderObjects,
        start=0,
        tail=len(list),
        time0=time0,
        time1=time1
    )

proc newBVHNode*(list: HittableList, start: int, tail: int, time0: float64, time1: float64): BVHNode =
    return buildBVH(
        objects=list.renderObjects,
        start=start,
        tail=tail,
        time0=time0,
        time1=time1
    )

method hit*(this: BVHNode, r: Ray, tMin: float64, tMax: float64, rec: var HitRecord): bool =
    if not this.box.hit(r, tMin, tMax):
        return false

    let
        hitLeft: bool = this.left.hit(r, tMin, tMax, rec)
        hitRight: bool = this.right.hit(r, tMin, if hitLeft: rec.t else: tMax, rec)

    return hitLeft or hitRight

method boundingBox*(this: BVHNode, time0: float64, time1: float64, outputBox: var AABB): bool =
    outputBox = this.box

    return true

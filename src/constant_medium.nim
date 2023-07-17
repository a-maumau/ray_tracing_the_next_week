import math

import rand
import vec3
import aabb
import renderable_object, material
import ray


type ConstantMedium* = ref object of Hittable
    boundary: Hittable
    negInvDensity: float64
    phaseFunction: Material

proc newConstantMedium*(obj: Hittable, d: float64, c: Color): ConstantMedium =
    return ConstantMedium(
        boundary: obj,
        negInvDensity: -1.0/d,
        phaseFunction: newIsotropic(c)
    )

proc newConstantMedium*(obj: Hittable, d: float64, mat: Material): ConstantMedium =
    return ConstantMedium(
        boundary: obj,
        negInvDensity: -1.0/d,
        phaseFunction: mat
    )

method hit*(this: ConstantMedium, r: Ray, tMin: float64, tMax: float64, rec: var HitRecord): bool =
    let
        enableDebug = false
        debugging: bool = enableDebug and (rand.rand() < 0.00001)

    var
        # tmp
        rec1 = newHitRecord(newPoint3(0, 0, 0), newVec3(0, 0, 0), 0.0)
        rec2 = newHitRecord(newPoint3(0, 0, 0), newVec3(0, 0, 0), 0.0)

    if not this.boundary.hit(r, -Inf, Inf, rec1):
        return false

    if not this.boundary.hit(r, rec1.t+0.0001, Inf, rec2):
        return false

    if debugging:
        echo "\nt_min=" & $rec1.t & ", t_max=" & $rec2.t;

    if rec1.t < tMin:
        rec1.t = tMin;
    if rec2.t > tMax:
        rec2.t = tMax;

    if rec1.t >= rec2.t:
        return false

    if rec1.t < 0:
        rec1.t = 0

    let
        rayLength = r.direction().length()
        distanceInsideBoundary = (rec2.t - rec1.t) * rayLength
        hitDistance = this.negInvDensity * ln(rand.rand())

    if hitDistance > distanceInsideBoundary:
        return false

    rec.t = rec1.t + hitDistance / rayLength
    rec.p = r.at(rec.t)

    if debugging:
        echo "hit_distance = " & $hit_distance & "\nrec.t = " & $rec.t & "\nrec.p = " & $rec.p

    rec.normal = newVec3(1, 0, 0)  # arbitrary
    rec.frontFace = true           # also arbitrary
    rec.mat = this.phaseFunction

    return true

method boundingBox*(this: ConstantMedium, time0: float64, time1: float64, outputBox: var AABB): bool =
    return this.boundary.boundingBox(time0, time1, outputBox);

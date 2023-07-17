import vec3
import ray


type AABB* = ref object of RootObj
    minimum, maximum: Point3

proc newAABB*(a: Point3, b: Point3): AABB =
    return AABB(minimum: a, maximum: b)

proc min*(this: AABB): Point3 =
    return this.minimum

proc max*(this: AABB): Point3 =
    return this.maximum

proc hit*(this: AABB, r: Ray, tMin: float64, tMax: float64): bool =
    var
        t0, t1: float64
        invD: float64
        tmp: float64

        tmptMin = tMin
        tmptMax = tMax

    for d in 0..<3:
        # original
        #t0 = min((this.minimum[d] - r.origin()[d]) / r.direction()[d], (this.maximum[d] - r.origin()[d]) / r.direction()[d])
        #t1 = max((this.minimum[d] - r.origin()[d]) / r.direction()[d], (this.maximum[d] - r.origin()[d]) / r.direction()[d])
        #tmptMin = max(t0, tmptMin)
        #tmptMax = min(t1, tmptMax)

        invD = 1.0 / r.direction()[d]
        t0 = (this.min()[d] - r.origin()[d]) * invD
        t1 = (this.max()[d] - r.origin()[d]) * invD

        # swap
        if invD < 0.0:
            tmp = t0
            t0 = t1
            t1 = tmp

        tmptMin = if t0 > tmptMin: t0 else: tmptMin
        tmptMax = if t1 < tmptMax: t1 else: tmptMax

        if tmptMax <= tmptMin:
            return false

    return true

proc surroundingBox*(box0: AABB, box1: AABB): AABB =
    var
        small: Point3 = newPoint3(
            min(box0.min().x(), box1.min().x()),
            min(box0.min().y(), box1.min().y()),
            min(box0.min().z(), box1.min().z())
        )

        big: Point3 = newPoint3(
            max(box0.max().x(), box1.max().x()),
            max(box0.max().y(), box1.max().y()),
            max(box0.max().z(), box1.max().z())
        )

    return newAABB(small, big)

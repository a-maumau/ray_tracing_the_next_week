import vec3


type Ray* = ref object of RootObj
    orig: Point3
    dir: Vec3
    time: float64

proc newRay*(orig: Point3, dir: Vec3, time: float64 = 0.0): Ray =
    return Ray(orig: orig, dir: dir, time: time)

proc origin*(this: Ray): Vec3 =
    return this.orig

proc direction*(this: Ray): Vec3 =
    return this.dir

proc time*(this: Ray): float64 =
    return this.time

proc at*(this: Ray, t: float64): Vec3 =
    return this.orig + t*this.dir

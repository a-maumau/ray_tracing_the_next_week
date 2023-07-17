import math

import vec3
import aabb
import material
import ray


type Hittable* = ref object of RootObj
    p: Point3
    normal: Vec3
    t: float64

method hit*(this: Hittable, r: Ray, tMin: float64, tMax: float64, rec: var HitRecord): bool {.base.} =
    raiseAssert("you need impl. this function.")

method boundingBox*(this: Hittable, time0: float64, time1: float64, outputBox: var AABB): bool {.base.} =
    raiseAssert("you need impl. this function.")

type Sphere* = ref object of Hittable
    center: Point3
    radius: float64
    mat: Material

proc newSphere*(center: Point3, radius: float64, mat: Material): Sphere =
    return Sphere(center: center, radius: radius, mat: mat)

proc getSphereUV(this: Sphere, p: Point3, u: var float64, v: var float64) = 
    # p: a given point on the sphere of radius one, centered at the origin.
    # u: returned value [0,1] of angle around the Y axis from X=-1.
    # v: returned value [0,1] of angle from Y=-1 to Y=+1.
    #     <1 0 0> yields <0.50 0.50>       <-1  0  0> yields <0.00 0.50>
    #     <0 1 0> yields <0.50 1.00>       < 0 -1  0> yields <0.50 0.00>
    #     <0 0 1> yields <0.25 0.50>       < 0  0 -1> yields <0.75 0.50>

    let
        theta = arccos(-p.y())
        phi = arctan2(-p.z(), p.x()) + Pi

    u = phi / (2*Pi);
    v = theta / Pi;

method hit*(this: Sphere, r: Ray, tMin: float64, tMax: float64, rec: var HitRecord): bool =
    var
        oc: Vec3 = r.origin() - this.center

        a: float64 = r.direction().lengthSquared()
        halfB: float64 = dot(oc, r.direction())
        c: float64 = oc.lengthSquared() - this.radius*this.radius

        discriminant: float64 = halfB*halfB - a*c;

    if discriminant < 0:
        return false
    
    var
        sqrtd: float64 = sqrt(discriminant)
        root: float64 = (-half_b - sqrtd) / a

    # find the nearest root that lies in the acceptable range (t_min, t_max)
    if root < tMin or tMax < root:
        root = (-half_b + sqrtd) / a

        if root < tMin or tMax < root:
            return false

    rec.t = root
    rec.p = r.at(rec.t)
    rec.normal = (rec.p - this.center) / this.radius
    let outwardNormal: Vec3 = (rec.p - this.center) / this.radius
    rec.setFaceNormal(r, outwardNormal)
    this.getSphereUV(outwardNormal, rec.u, rec.v)
    rec.mat = this.mat

    return true

method boundingBox*(this: Sphere, time0: float64, time1: float64, outputBox: var AABB): bool =
    outputBox = newAABB(
        this.center - newVec3(this.radius, this.radius, this.radius),
        this.center + newVec3(this.radius, this.radius, this.radius)
    )

    return true

type MovingSphere* = ref object of Hittable
    center0, center1: Point3
    time0, time1: float64
    radius: float64
    mat: Material

proc newMovingSphere*(
    center0, center1: Point3,
    time0: float64,
    time1: float64,
    radius: float64,
    mat: Material
): MovingSphere =
    return MovingSphere(
        center0: center0,
        center1: center1,
        time0: time0,
        time1: time1,
        radius: radius,
        mat: mat
    )

proc center*(this: MovingSphere, time: float64): Point3 =
    return this.center0 + ((time-this.time0) / (this.time1-this.time0))*(this.center1-this.center0)

method hit*(this: MovingSphere, r: Ray, tMin: float64, tMax: float64, rec: var HitRecord): bool =
    var
        oc: Vec3 = r.origin() - this.center(r.time())

        a: float64 = r.direction().lengthSquared()
        halfB: float64 = dot(oc, r.direction())
        c: float64 = oc.lengthSquared() - this.radius*this.radius

        discriminant: float64 = halfB*halfB - a*c;

    if discriminant < 0:
        return false
    
    var
        sqrtd: float64 = sqrt(discriminant)
        root: float64 = (-half_b - sqrtd) / a

    # find the nearest root that lies in the acceptable range (t_min, t_max)
    if root < tMin or tMax < root:
        root = (-half_b + sqrtd) / a

        if root < tMin or tMax < root:
            return false

    rec.t = root
    rec.p = r.at(rec.t)

    let outwardNormal: Vec3 = (rec.p - this.center(r.time())) / this.radius
    rec.setFaceNormal(r, outwardNormal)
    rec.mat = this.mat

    return true

method boundingBox*(this: MovingSphere, time0: float64, time1: float64, outputBox: var AABB): bool =
    var
        box0 = newAABB(
            this.center(time0) - newVec3(this.radius, this.radius, this.radius),
            this.center(time0) + newVec3(this.radius, this.radius, this.radius)
        )

        box1 = newAABB(
            this.center(time1) - newVec3(this.radius, this.radius, this.radius),
            this.center(time1) + newVec3(this.radius, this.radius, this.radius)
        )
   
    outputBox = surroundingBox(box0, box1)

    return true

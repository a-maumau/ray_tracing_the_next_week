import math

import rand
import vec3
import texture
import ray


type Material* = ref object of RootObj

type HitRecord* = ref object of RootObj
    p*: Point3
    t*: float64
    u*, v*: float64
    normal*: Vec3
    frontFace*: bool
    mat*: Material

method scatter*(this: Material, r_in: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool {.base.} =
    raiseAssert("you need impl. this function.")

method emitted*(this: Material, u: float64, v: float64, p: Point3): Color {.base.} =
    return newColor(0, 0, 0)

proc newHitRecord*(p: Point3, n: Vec3, t: float64): HitRecord =
    return HitRecord(p: p, normal: n, t: t)

proc setFaceNormal*(this: HitRecord, r: Ray, outwardNormal: Vec3) =
    this.frontFace = dot(r.direction(), outwardNormal) < 0
    this.normal = if this.frontFace: outwardNormal else: -outwardNormal

type Lambertian* = ref object of Material
    albedo: Texture

proc newLambertian*(color: Color): Lambertian =
    return Lambertian(albedo: newSolidColor(color))

proc newLambertian*(texture: Texture): Lambertian =
    return Lambertian(albedo: texture)

method scatter*(this: Lambertian, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool =
    var scatterDirection: Vec3 = rec.normal + randomUnitVector()

    # catch degenerate scatter direction
    if (scatterDirection.nearZero()):
        scatterDirection = rec.normal

    scattered = newRay(rec.p, scatterDirection, rIn.time())
    attenuation = this.albedo.value(rec.u, rec.v, rec.p)

    return true

type Metal* = ref object of Material
    albedo: Color
    fuzz: float64

proc newMetal*(color: Color, f: float64 = 0.0): Metal =
    return Metal(albedo: color, fuzz: f)

method scatter*(this: Metal, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool =
    var reflected: Vec3 = reflect(unitVector(rIn.direction()), rec.normal)

    scattered = newRay(rec.p, reflected + this.fuzz*randomInUnitSphere(), rIn.time())
    attenuation = this.albedo

    return dot(scattered.direction(), rec.normal) > 0

type Dielectric* = ref object of Material
    # index of refraction
    ir: float64

proc newDielectric*(indexOfRefraction: float64): Dielectric =
    return Dielectric(ir: indexOfRefraction)

proc reflectance(cosine: float64, refIdx: float64): float64 =
    # use Schlick's approximation for reflectance.
    var r0 = (1-refIdx) / (1+refIdx)

    r0 = r0*r0

    return r0 + (1-r0)*pow((1 - cosine), 5)

method scatter*(this: Dielectric, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool =
    attenuation = newColor(1.0, 1.0, 1.0)

    var
        refractionRatio: float64 = if rec.frontFace: 1.0/this.ir else: this.ir

        unitDirection: Vec3 = unitVector(rIn.direction())
        cosTheta: float64 = min(dot(-unitDirection, rec.normal), 1.0)
        sinTheta: float64 = sqrt(1.0 - cosTheta*cosTheta)

        cannotRefract: bool = refractionRatio * sinTheta > 1.0
        direction: Vec3

    if cannotRefract or reflectance(cosTheta, refractionRatio) > rand():
        direction = reflect(unit_direction, rec.normal)
    else:
        direction = refract(unit_direction, rec.normal, refraction_ratio)
    
    scattered = newRay(rec.p, direction, rIn.time())

    return true

type DiffuseLight* = ref object of Material
    emit: Texture

proc newDiffuseLight*(tex: Texture): DiffuseLight =
    return DiffuseLight(emit: tex)

proc newDiffuseLight*(col: Color): DiffuseLight =
    return DiffuseLight(emit: newSolidColor(col))

method scatter*(this: DiffuseLight, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool =
    return false

method emitted*(this: DiffuseLight, u: float64, v: float64, p: Point3): Color =
    return this.emit.value(u, v, p)

type Isotropic* = ref object of Material
    albedo: Texture

proc newIsotropic*(col: Color): Isotropic =
    return Isotropic(albedo: newSolidColor(col))

proc newIsotropic*(tex: Texture): Isotropic =
    return Isotropic(albedo: tex)

method scatter*(this: Isotropic, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool =
    scattered = newRay(rec.p, vec3.randomInUnitSphere(), rIn.time())
    attenuation = this.albedo.value(rec.u, rec.v, rec.p);

    return true

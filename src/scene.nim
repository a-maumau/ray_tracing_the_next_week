#[
    scene setup for the Ray Tracing: The Next Week
]#
import math
import std/cpuinfo
import strformat
import system

import rand
import vec3
import bvh
import camera, film, render
import renderable_object, hittable_list, material, texture
import plane, box, transform
import constant_medium
import misc


proc createCamera(film: Film, sceneNum: int): Camera = 
    case sceneNum:
        of 0:
            var
                lookFrom: Point3 = newPoint3(0, 400, 1000)
                lookAt: Point3 = newPoint3(0, 0, 0)
                vup: Vec3 = newVec3(0, 1, 0)
                distToFocus: float64 = 10.0
                aperture: float64 = 0.0

                # camera setup
                cam: Camera = newCamera(
                    film=film,
                    lookFrom=lookFrom,
                    lookAt=lookAt,
                    vup=vup,
                    vfov=40.0,
                    aperture=aperture,
                    focusDist=distToFocus,
                    time0=0.0,
                    time1=1.0
                )

            return cam
        of 1..2:
            var
                lookFrom: Point3 = newPoint3(13, 2, 3)
                lookAt: Point3 = newPoint3(0, 0, 0)
                vup: Vec3 = newVec3(0, 1, 0)
                distToFocus: float64 = 10.0
                aperture: float64 = 0.1

                # camera setup
                cam: Camera = newCamera(
                    film=film,
                    lookFrom=lookFrom,
                    lookAt=lookAt,
                    vup=vup,
                    vfov=20.0,
                    aperture=aperture,
                    focusDist=distToFocus,
                    time0=0.0,
                    time1=1.0
                )
            return cam
        of 3..5:
            var
                lookFrom: Point3 = newPoint3(26, 3, 6)
                lookAt: Point3 = newPoint3(0, 2, 0)
                vup: Vec3 = newVec3(0, 1, 0)
                distToFocus: float64 = 10.0
                aperture: float64 = 0.0

                # camera setup
                cam: Camera = newCamera(
                    film=film,
                    lookFrom=lookFrom,
                    lookAt=lookAt,
                    vup=vup,
                    vfov=20.0,
                    aperture=aperture,
                    focusDist=distToFocus,
                    time0=0.0,
                    time1=1.0
                )

            return cam
        of 6..7:
            var
                lookFrom: Point3 = newPoint3(278, 278, -800)
                lookAt: Point3 = newPoint3(278, 278, 0)
                vup: Vec3 = newVec3(0, 1, 0)
                distToFocus: float64 = 10.0
                aperture: float64 = 0.0

                # camera setup
                cam: Camera = newCamera(
                    film=film,
                    lookFrom=lookFrom,
                    lookAt=lookAt,
                    vup=vup,
                    vfov=40.0,
                    aperture=aperture,
                    focusDist=distToFocus,
                    time0=0.0,
                    time1=1.0
                )

            return cam
        of 8:
            var
                lookFrom: Point3 = newPoint3(478, 278, -600)
                lookAt: Point3 = newPoint3(278, 278, 0)
                vup: Vec3 = newVec3(0, 1, 0)
                distToFocus: float64 = 10.0
                aperture: float64 = 0.0

                # camera setup
                cam: Camera = newCamera(
                    film=film,
                    lookFrom=lookFrom,
                    lookAt=lookAt,
                    vup=vup,
                    vfov=40.0,
                    aperture=aperture,
                    focusDist=distToFocus,
                    time0=0.0,
                    time1=1.0
                )

            return cam
        else:
            var
                lookFrom: Point3 = newPoint3(13, 2, 3)
                lookAt: Point3 = newPoint3(0, 0, 0)
                vup: Vec3 = newVec3(0, 1, 0)
                distToFocus: float64 = 10.0
                aperture: float64 = 0.0

                # camera setup
                cam: Camera = newCamera(
                    film=film,
                    lookFrom=lookFrom,
                    lookAt=lookAt,
                    vup=vup,
                    vfov=20.0,
                    aperture=aperture,
                    focusDist=distToFocus,
                    time0=0.0,
                    time1=1.0
                )

            return cam

proc createWorld(sceneNum: int): HittableList =
    var
        # world object
        world: HittableList = newHittableList()

    case sceneNum:
        # debug
        of 0:
            let innerWorld: HittableList = newHittableList()
            let matLight = newDiffuseLight(newColor(6, 6, 6))
            innerWorld.add(newPlaneXZ(-150.0, 150.0, -200.0, 500.0, 400.0, matLight))

            let imageTexture = newImageTexture("./resource/square_256_256.png", 16, 16)
            innerWorld.add(newPlaneXZ(-10000.0, 10000.0, -10000.0, 10000.0, 0.0, newLambertian(imageTexture)))

            let matSphere = newLambertian(newImageTexture("./resource/square_1024_512.png", 2, 2))
            world.add(newSphere(newPoint3(0, 0, 0), 100, matSphere))

            var
                boxes = newHittableList()
                matWhite: Lambertian = newLambertian(newColor(0.73, 0.73, 0.73))
            for i in 0..<12:
                let
                    x = sin(degreesToRadians(float(i*30)))
                    z = -cos(degreesToRadians(float(i*30)))
                    col = HSVToRGB(i*30, 255, 255)

                boxes.add(
                    newTranslate(
                        newRotateY(
                            newBox(newPoint3(0, 0, 0), newPoint3(80, 80, 80), newLambertian(col)),
                            float(-i*30-5)
                        ),
                        newVec3(300.0*x, 0, 300.0*z)
                    )
                )
            for i in 0..<24:
                let
                    x = sin(degreesToRadians(float(i*15)))
                    z = -cos(degreesToRadians(float(i*15)))
                boxes.add(
                    newTranslate(
                        newRotateY(
                            newBox(newPoint3(0, 0, 0), newPoint3(80, 80, 80), matWhite),
                            float(-i*15-5)
                        ),
                        newVec3(450.0*x, 0, 450.0*z)
                    )
                )
            innerWorld.add(newBVHNode(boxes, 0.0, 1.0))
            world.add(newBVHNode(innerWorld, 0.0, 1.0))

        of 1:
            let
                checker: CheckerTexture = newCheckerTexture(newColor(0.2, 0.3, 0.1), newColor(0.9, 0.9, 0.9))
                materialGround: Lambertian = newLambertian(checker)
                material1: Dielectric = newDielectric(1.5)
                material2: Lambertian = newLambertian(newColor(0.4, 0.2, 0.1))
                material3: Metal = newMetal(newColor(0.7, 0.6, 0.5), 0.0)

            # add objects in the world
            world.add(newSphere(newPoint3( 0.0, -1000.0, -1.0), 1000.0, materialGround))
            world.add(newSphere(newPoint3( 0.0, 1.0, 0.0), 1.0, material1))
            world.add(newSphere(newPoint3(-4.0, 1.0, 0.0), 1.0, material2))
            world.add(newSphere(newPoint3( 4.0, 1.0, 0.0), 1.0, material3))

            # add random small balls
            for a in -11..<11:
                for b in -11..<11:
                    var
                        chooseMat: float64 = rand()
                        center: Point3 = newPoint3(float64(a)+0.9*rand(), 0.2, float64(b)+0.9*rand())

                    if (center-newPoint3(4, 0.2, 0)).length() > 0.9:
                        var sphereMaterial: Material

                        if chooseMat < 0.8:
                            # diffuse
                            sphereMaterial = newLambertian(vec3.random()*vec3.random())
                            let center2: Point3 = center + newPoint3(0.0, rand(0, 0.5), 0.0)
                            #world.add(newSphere(center, 0.2, sphereMaterial))
                            world.add(newMovingSphere(center, center2, 0.0, 1.0, 0.2, sphereMaterial))
                        elif choose_mat < 0.95:
                            # metal
                            sphereMaterial = newMetal(random(0.5, 1), rand(0, 0.5))
                            world.add(newSphere(center, 0.2, sphereMaterial))
                        else:
                            # glass
                            sphereMaterial = newDielectric(1.5)
                            world.add(newSphere(center, 0.2, sphereMaterial))

        of 2:
            let
                checker: CheckerTexture = newCheckerTexture(newColor(0.2, 0.3, 0.1), newColor(0.9, 0.9, 0.9))
                materialGround: Lambertian = newLambertian(checker)
            world.add(newSphere(newPoint3(0.0, -10.0, 0.0), 10.0, materialGround))
            world.add(newSphere(newPoint3(0.0, 10.0, 0.0), 10.0, materialGround))

        of 3:
            let pertext: NoiseTexture = newNoiseTexture(4)
            world.add(newSphere(newPoint3( 0.0, -1000.0, 0.0), 1000.0, newLambertian(pertext)))
            world.add(newSphere(newPoint3( 0.0, 2.0, 0.0), 2.0, newLambertian(pertext)))
        of 4:
            let
                # this one loads the image which I made it by myself
                imageTexture = newImageTexture("./resource/square_1024_512.png")
                # you can grab the image on the book
                # they say they grab from the web, but I don't know about license of the image
                # so I will comment out the code which reads that image
                #imageTexture = newImageTexture("./resource/earthmap.jpeg")
                sphereSuface: Lambertian = newLambertian(imageTexture)

            world.add(newSphere(newPoint3(0.0, 0.0, 0.0), 2, sphereSuface))

        of 5:
            let pertext: NoiseTexture = newNoiseTexture(4)
            world.add(newSphere(newPoint3( 0.0, -1000.0, 0.0), 1000.0, newLambertian(pertext)))
            world.add(newSphere(newPoint3( 0.0, 2.0, 0.0), 2.0, newLambertian(pertext)))

            let diffLight: DiffuseLight = newDiffuseLight(newColor(4, 4, 4))
            world.add(newPlaneXY(3.0, 5.0, 1.0, 3.0, -2.0, diffLight))

        # cornell box
        of 6:
            let
                matRed: Lambertian = newLambertian(newColor(0.65, 0.05, 0.05))
                matWhite: Lambertian = newLambertian(newColor(0.73, 0.73, 0.73))
                matGreen: Lambertian = newLambertian(newColor(0.12, 0.45, 0.15))
                matLight: DiffuseLight = newDiffuseLight(newColor(15, 15, 15))

                box1 = newTranslate(
                    newRotateY(
                        newBox(newPoint3(0, 0, 0), newPoint3(165, 330, 165), matWhite)
                    , 15),
                    newVec3(265, 0, 295)
                )

                box2 = newTranslate(
                    newRotateY(
                        newBox(newPoint3(0, 0, 0), newPoint3(165, 165, 165), matWhite)
                    , -18),
                    newVec3(130, 0, 65)
                )

            world.add(newPlaneYZ(0.0, 555.0, 0.0, 555.0, 555.0, matGreen))
            world.add(newPlaneYZ(0.0, 555.0, 0.0, 555.0, 0.0, matRed))

            world.add(newPlaneXZ(213.0, 343.0, 227.0, 332.0, 554.0, matLight))
            world.add(newPlaneXZ(0.0, 555.0, 0.0, 555.0, 0.0, matWhite))            
            world.add(newPlaneXZ(0.0, 555.0, 0.0, 555.0, 555.0, matWhite))

            world.add(newPlaneXY(0.0, 555.0, 0.0, 555.0, 555.0, matWhite))

            world.add(box1)
            world.add(box2)

        # cornell smoke
        of 7:
            let
                matRed: Lambertian = newLambertian(newColor(0.65, 0.05, 0.05))
                matWhite: Lambertian = newLambertian(newColor(0.73, 0.73, 0.73))
                matGreen: Lambertian = newLambertian(newColor(0.12, 0.45, 0.15))
                matLight: DiffuseLight = newDiffuseLight(newColor(7, 7, 7))

                box1 = newTranslate(
                    newRotateY(
                        newBox(newPoint3(0, 0, 0), newPoint3(165, 330, 165), matWhite)
                    , 15),
                    newVec3(265, 0, 295)
                )

                box2 = newTranslate(
                    newRotateY(
                        newBox(newPoint3(0, 0, 0), newPoint3(165, 165, 165), matWhite)
                    , -18),
                    newVec3(130, 0, 65)
                )

            var boxes1 = newHittableList()
            boxes1.add(newPlaneYZ(0.0, 555.0, 0.0, 555.0, 555.0, matGreen))
            boxes1.add(newPlaneYZ(0.0, 555.0, 0.0, 555.0, 0.0, matRed))

            boxes1.add(newPlaneXZ(113.0, 443.0, 127.0, 432.0, 554.0, matLight))
            boxes1.add(newPlaneXZ(0.0, 555.0, 0.0, 555.0, 0.0, matWhite))            
            boxes1.add(newPlaneXZ(0.0, 555.0, 0.0, 555.0, 555.0, matWhite))

            boxes1.add(newPlaneXY(0.0, 555.0, 0.0, 555.0, 555.0, matWhite))
            world.add(newBVHNode(boxes1, 0.0, 1.0))

            world.add(newConstantMedium(box1, 0.01, newColor(0, 0, 0)))
            world.add(newConstantMedium(box2, 0.01, newColor(1, 1, 1)))

        # final scene
        of 8:
            const boxes_per_side = 20

            var boxes1 = newHittableList()
            let matGround = newLambertian(newColor(0.48, 0.83, 0.53))
            for i in 0..<boxes_per_side:
                for j in 0..<boxes_per_side:
                    let
                        w = 100.0
                        x0 = -1000.0 + float(i)*w
                        z0 = -1000.0 + float(j)*w
                        y0 = 0.0
                        x1 = x0 + w
                        y1 = rand.rand(1.0, 101.0)
                        z1 = z0 + w

                    boxes1.add(newBox(newPoint3(x0,y0,z0), newPoint3(x1,y1,z1), matGround))

            world.add(newBVHNode(boxes1, 0.0, 1.0))

            let matLight = newDiffuseLight(newColor(7, 7, 7))
            world.add(newPlaneXZ(123.0, 423.0, 147.0, 412.0, 554.0, matLight))

            let matMovingSphere = newLambertian(newColor(0.7, 0.3, 0.1))
            let centerMSP = newPoint3(400, 400, 200)
            world.add(newMovingSphere(centerMSP, centerMSP+newVec3(30, 0, 0), 0, 1, 50, matMovingSphere))

            world.add(newSphere(newPoint3(260, 150, 45), 50, newDielectric(1.5)))
            world.add(newSphere(newPoint3(0, 150, 145), 50, newMetal(newColor(0.8, 0.8, 0.9), 1.0)))

            let boundary1 = newSphere(newPoint3(360, 150, 145), 70, newDielectric(1.5))
            world.add(boundary1)
            world.add(newConstantMedium(boundary1, 0.2, newColor(0.2, 0.4, 0.9)))

            let boundary2 = newSphere(newPoint3(0, 0, 0), 5000, newDielectric(1.5))
            world.add(boundary2)
            world.add(newConstantMedium(boundary2, 0.0001, newColor(1.0, 1.0, 1.0)))

            let matImgMat = newLambertian(newImageTexture("./resource/square_1024_512.png"))
            world.add(newSphere(newPoint3(400, 200, 400), 100, matImgMat))

            let pertext = newNoiseTexture(0.1)
            world.add(newSphere(newPoint3(220, 280, 300), 80, newLambertian(pertext)))

            var boxes2 = newHittableList()
            let matWhite = newLambertian(newColor(0.73, 0.73, 0.73))
            for j in 0..<1000:
                boxes2.add(newSphere(vec3.random(0.0, 165.0), 10, matWhite))

            world.add(
                newTranslate(
                    newRotateY(newBVHNode(boxes2, 0.0, 1.0), 15),
                    newVec3(-100, 270, 395)
                )
            )

        else:
            discard

    return world

proc renderScene*() =
    const
        sceneNum = 0
        outputPath = "./outputs/rendered_img.ppm"

        samplesPerPixel: int = 1024
        maxDepth: int = 50

    var
        # output image setup
        aspectRatio: float
        imageWidth: int
        imageHeight: int

    if sceneNum >= 8:
        # output image setup
        aspectRatio = 1.0
        imageWidth = 800
        imageHeight = int(float(imageWidth) / aspectRatio)
    else:
        # output image setup
        aspectRatio = 3.0 / 2.0
        imageWidth = 300
        imageHeight = int(float(imageWidth) / aspectRatio)

    var
        film: Film = newFilm(imageWidth, imageHeight)

        # camera setup
        cam: Camera

        # world object
        world: HittableList

        renderer: Renderer

    echo("creating scene...")
    cam = createCamera(film, sceneNum)
    world = createWorld(sceneNum)

    var bgColor: Color
    if sceneNum == 0:
        bgColor = newColor(0.0, 0.0, 0.0)
    elif sceneNum >= 5:
        bgColor = newColor(0.0, 0.0, 0.0)
    else:
        bgColor = newColor(0.7, 0.8, 1.0)

    renderer = newRenderer(cam, world, samplesPerPixel, maxDepth, bgColor)

    # run with all core
    echo("start rendering...")
    #renderer.compute()
    renderer.compute(threadNum=countProcessors())
    echo("finished rendering!")

    echo(fmt"save at {outputPath}")
    renderer.saveImage(outputPath)

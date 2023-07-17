import math
import strformat
import threadpool
import times
{.experimental: "parallel".}

import rand
import vec3
import camera, film
import renderable_object, hittable_list, material
import ray
import io/ppm
import misc


type ThreadTaskProgress = tuple
    threadId: int
    heightCount: int

type Renderer* = ref object of RootObj
    camera*: Camera
    world*: HittableList
    samplesPerPixel*: int
    maxDepth*: int
    backgroundColor: Color

proc newRenderer*(
    camera: Camera,
    world: HittableList,
    samplesPerPixel: int,
    maxDepth: int,
    backgroundColor: Color = newColor(0.0, 0.0, 0.0)
): Renderer =
    return Renderer(
        camera: camera,
        world: world,
        samplesPerPixel: samplesPerPixel,
        maxDepth: maxDepth,
        backgroundColor: backgroundColor
    )

proc rayColor(world: Hittable, background: Color, r: Ray, depth: int): Color =
    if depth <= 0:
        return newColor(0, 0, 0)

    var
        rec: HitRecord
        scattered: Ray
        attenuation: Color
        emitted: Color

    # if the ray hits nothing, return the background color
    if not world.hit(r, 0.001, Inf, rec):
        return background

    emitted = rec.mat.emitted(rec.u, rec.v, rec.p)

    if not rec.mat.scatter(r, rec, attenuation, scattered):
        return emitted

    return emitted + attenuation * rayColor(world, background, scattered, depth-1)

#type ThreadArgs = tuple
#    this: Renderer
#    panePixels: seq[Color]
#    width: int
#    height: int
#    samplesPerPixel: int
#    threadId: int
#    channel: Channel[ThreadTaskProgress]

proc threadCompute(
    this: Renderer,
    panePixels: var seq[Color],
    width: int,
    height: int,
    samplesPerPixel: int,
    threadId: int,
    channel: ptr Channel[ThreadTaskProgress]
) {.thread.} =
    var
        u, v: float64
        #pixelColor: Color
        pixelColor = newColor(0, 0, 0)

    #for h in countdown(height-1, 0):
    for h in 0..<height:
        for w in 0..<width:
            pixelColor.setToZero()

            for i in 0..<samplesPerPixel:
                u = (float64(w)+rand())/float64(this.camera.film.width-1)
                v = (float64(h)+rand())/float64(this.camera.film.height-1)

                pixelColor += rayColor(this.world, this.backgroundColor, this.camera.getRay(u, v), this.maxDepth)

            panePixels[h*width + w].setTo(pixelColor)

        # for sharing the progress
        channel[].send((threadId, h+1))

proc compute*(this: Renderer) =
    ## compute the raytracing in a single core.
    var
        width: int = this.camera.film.width
        height: int = this.camera.film.height

        u, v: float64
        pixelColor: Color = newColor(0, 0, 0)

    # clear the remaining image on film
    this.camera.film.clear()

    for h in countdown(height-1, 0):
        stdout.write("\rScanlines remaining: ", fmt"{h:>3}")
        flushFile(stdout)
    
        for w in 0..<width:
            pixelColor.setToZero()
    
            for i in 0..<this.samplesPerPixel:
                u = (float64(w)+rand())/float64(width-1)
                v = (float64(h)+rand())/float64(height-1)

                pixelColor += rayColor(this.world, this.backgroundColor, this.camera.getRay(u, v), this.maxDepth)

            this.camera.film[h*width + w] = this.camera.film[h*width + w]+pixelColor

    stdout.write("\n")

proc compute*(this: Renderer, threadNum: int) =
    ## compute the raytracing with given thread nums

    var
        width = this.camera.film.width
        height = this.camera.film.height

        samplePerThread = int(this.samplesPerPixel/threadNum)
        samplePerPixelRemain = this.samplesPerPixel - samplePerThread*threadNum
        parallelColor: seq[seq[Color]] = @[]

        # create a new channel that is used for calc. ETA
        #channel = Channel[ThreadTaskProgress]()
        # see https://nim-lang.org/docs/channels_builtin.html#Channel
        channel = cast[ptr Channel[ThreadTaskProgress]](allocShared0(sizeof(Channel[ThreadTaskProgress])))

        #threads: seq[Thread[ThreadArgs]] = newSeq[Thread[ThreadArgs]](threadNum)
        eachThreadProgress: seq[int] = newSeq[int](threadNum)

    for th in 0..<threadNum:
        parallelColor.add(newSeq[Color](width*height))
        for i in 0..<height*width:
            parallelColor[th][i] = newColor(0, 0, 0)

    # clear the remaining image on film
    this.camera.film.clear()

    channel[].open()

    let
        updatefrequency: float = 2.0 # in sec.
        totalHeightCount: int = height*threadNum

    var
        prevTime: float = epochTime()
        currTime: float = 0.0
        prevProgress: int = 0
        prevStringLen: int = 35
        progressMsgStr: string = ""

    # it seems implementing like this will allocate a new memory,
    # so the image size matter creating some threads
    # need to be fixed
    parallel:
        for th in 0..<threadNum:
            if th == 0:
                # add the fraction, assuming thread: 0 will be finish fastest
                spawn(this.threadCompute(parallelColor[th], width, height, samplePerThread+samplePerPixelRemain, th, channel))
            else:
                spawn(this.threadCompute(parallelColor[th], width, height, samplePerThread, th, channel))
            echo fmt"thread {th} has started."

        stdout.write(fmt"ETA - (  0%): waiting for update...")
        flushFile(stdout)
        # this is a bad code...
        while true:
            let (tId, currHeightProgress) = channel[].recv()
            # rendering is done in bottom to top way
            #eachThreadProgress[tId] = width-currHeightProgress
            eachThreadProgress[tId] = currHeightProgress

            let totalProgress = eachThreadProgress.sum()
            if totalProgress == totalHeightCount:
                break
            else:
                currTime = epochTime()
                if updatefrequency > currTime - prevTime:
                    continue

                let
                    elapsed = currTime - prevTime
                    eta = float(totalHeightCount - totalProgress)/(float(totalProgress-prevProgress)/elapsed)

                # erasing the last output
                stdout.write("\r")
                for i in 0..prevStringLen:
                    stdout.write(" ")

                progressMsgStr = epochTimeToString(eta)
                prevStringLen = progressMsgStr.len()+11 # 11 for other texts
                stdout.write("\r", fmt"ETA {progressMsgStr} ({int((totalProgress/totalHeightCount)*100): 3}%)")
                flushFile(stdout)

                prevTime = currTime
                prevProgress = totalProgress

        stdout.write("\n")

    # clean up the channel
    close(channel[])
    deallocShared(channel)

    for th in 0..<threadNum:
        for i in 0..<height*width:
            this.camera.film[i] = this.camera.film[i]+parallelColor[th][i]

proc saveImage*(this: Renderer, filePath: string) =
    saveImagePPM(filePath, this.camera.film, this.samplesPerPixel)

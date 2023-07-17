import math
import strformat

import vec3


proc degreesToRadians*(degrees: float64): float64 =
    return degrees * PI / 180.0

proc clamp*(x: float64, min: float64, max: float64): float64 =
    if x < min: return min
    if x > max: return max
    return x

proc epochTimeToString*(t: float64): string =
    const
        minute: int = 60
        hour: int = 3600
        day: int = 3600*24

    var
        remaining: int = int(t+0.5)
        str: string = ""

    if remaining >= day:
        let dayNum = remaining mod day
        remaining = remaining - day*dayNum
        let hourNum = remaining mod hour
        remaining = remaining - day*hourNum
        let minuteNum = remaining mod minute
        remaining = remaining - day*minuteNum

        if dayNum > 0:
            str = str & fmt"{dayNum} d"

        if hourNum > 0:
            str = str & fmt"{hourNum} h"

        if minuteNum > 0:
            str = str & fmt"{minuteNum} min"

        return str

    elif remaining >= hour:
        let hourNum = remaining mod hour
        remaining = remaining - day*hourNum
        let minuteNum = remaining mod minute
        remaining = remaining - day*minuteNum

        if hourNum > 0:
            str = str & fmt"{hourNum} h"

        if minuteNum > 0:
            str = str & fmt"{minuteNum} min"

        return str

    elif remaining >= minute:
        let minuteNum = remaining mod minute
        remaining = remaining - day*minuteNum

        if minuteNum > 0:
            str = str & fmt"{minuteNum} min"

        if remaining > 0:
            str = str & fmt"{remaining} sec"

        return str

    # case of only seconds
    else:
        str = str & fmt"{remaining} sec"

        return str

proc HSVToRGB*(h: int, s: int, v: int): Color =
    ## s, v should be ranged in [0, 255]

    var
        maxV: float = float(v)
        minV: float = maxV-(float(s)/255.0)*float(maxV)
        diffV: float = float(maxV-minV)

    if h <= 60:
        let
            r = float(maxV)/255.0
            g = float((float(h)/60.0)*diffV+minV)/255.0
            b = float(minV)/255.0

        return newColor(r, g, b)
    elif h <= 120:
        let
            r = float((float(120-h)/60.0)*diffV+minV)/255.0
            g = float(maxV)/255.0
            b = float(minV)/255.0
        return newColor(r, g, b)
    elif h <= 180:
        let
            r = float(minV)/255.0
            g = float(maxV)/255.0
            b = float((float(h-120)/60.0)*diffV+minV)/255.0
        return newColor(r, g, b)
    elif h <= 240:
        let
            r = float(minV)/255.0
            g = float((float(240-h)/60.0)*diffV+minV)/255.0
            b = float(maxV)/255.0
        return newColor(r, g, b)
    elif h <= 300:
        let
            r = float((float(h-240)/60.0)*diffV+minV)/255.0
            g = float(minV)/255.0
            b = float(maxV)/255.0
        return newColor(r, g, b)
    elif h <= 360:
        let
            r = float(maxV)/255.0
            g = float(minV)/255.0
            b = float((float(360-h)/60.0)*diffV+minV)/255.0
        return newColor(r, g, b)
    else:
        let normH: int = h mod 360

        return HSVToRGB(normH, s, v)

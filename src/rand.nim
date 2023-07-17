import std/random


proc rand*(): float64 =
    ## returns [0, 1)
    return rand(0.999999999)

proc rand*(minVal: float64, maxVal: float64): float64 =
    ## returns [minVal, maxVal)
    return minVal + (maxVal-minVal)*rand()

proc randInt*(min: int, max: int): int =
    ## returns [min,max]
    return int(rand(float64(min), float64(max+1)))

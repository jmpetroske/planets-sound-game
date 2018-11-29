import math
import numpy as np
from PyAstronomy import pyasl

mu = 10000000

def calculateStartingParams(period, e, tau, Omega, w, i):
    a = (mu * math.pow(period, 2) / (4 * (math.pi ** 2))) ** (1 / 3)
    orbit = pyasl.KeplerEllipse(a, period, e, tau, Omega, w, i)
    return np.append(orbit.xyzPos(0), orbit.xyzVel(0))

print(calculateStartingParams(30, 0.00, 0, 0, 0, 0))

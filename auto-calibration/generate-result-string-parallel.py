
import math
import sys

path = '/home/liu/Desktop/out/result-temp' + str(sys.argv[2]) + '.txt'
result_temp_file = open(path, 'r')
lines = result_temp_file.readlines()

resultString = ""
for line in lines:
    if line.startswith("RANSAC Result"):
        resultString = line

resultString = resultString[38:]
valueStrings = resultString.split(", ")

x = float(valueStrings[0])
y = float(valueStrings[1])
z = float(valueStrings[2])
roll = float(valueStrings[3]) * 180 / math.pi
pitch = float(valueStrings[4]) * 180 / math.pi
yaw = float(valueStrings[5]) * 180 / math.pi

print("  <Device roll=\"" + str(roll) + "\" pitch=\"" + str(pitch) + "\" yaw=\"" + str(yaw) + "\" x=\"" + str(x) + "\" y=\"" + str(y) + "\" z=\"" + str(z) + "\">" + str(sys.argv[1]) + "</Device>")


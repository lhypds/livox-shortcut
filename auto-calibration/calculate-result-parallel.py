
import math
import sys

# sys.argv[1] is the target device ID
# sys.argv[2] is first-result.xml path
# sys.argv[2] is parallel instance ID (1~)

# Current result
path = '/home/liu/livox/out/result-temp-' + str(sys.argv[3]) +'.txt'
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

# First result - this result
path = str(sys.argv[2])
first_result_file = open(path, 'r')
lines = first_result_file.readlines()

for line in lines:
    if str(sys.argv[1]) in line:
        valueForThisDeviceline = line

valueStrings = valueForThisDeviceline.split(" ")
for valueString in valueStrings:
    if "x=" in valueString:
        if "e" in valueString: x1 = 0
        else: x1 = float(valueString.replace('x=', '').replace('\"', ''))
    elif "y=" in valueString:
        if "e" in valueString: y1 = 0
        else: y1 = float(valueString.replace('y=', '').replace('\"', ''))
    elif "z=" in valueString:
        if "e" in valueString: z1 = 0
        else: z1 = float(valueString.replace('z=', '').replace('\"', ''))
    elif "roll=" in valueString:
        if "e" in valueString: roll1 = 0
        else: roll1 = float(valueString.replace('roll=', '').replace('\"', ''))
    elif "pitch=" in valueString:
        if "e" in valueString: pitch1 = 0
        else: pitch1 = float(valueString.replace('pitch=', '').replace('\"', ''))
    elif "yaw=" in valueString:
        if "e" in valueString: yaw1 = 0
        else: yaw1 = float(valueString.replace('yaw=', '').replace('\"', ''))

x = x1 + x
y = y1 + y
z = z1 + z
roll = roll1 + roll
pitch = pitch1 + pitch
yaw = yaw1 + yaw

print("  <Device roll=\"" + str(roll) + "\" pitch=\"" + str(pitch) + "\" yaw=\"" + str(yaw) + "\" x=\"" + str(x) + "\" y=\"" + str(y) + "\" z=\"" + str(z) + "\">" + str(sys.argv[1]) + "</Device>")

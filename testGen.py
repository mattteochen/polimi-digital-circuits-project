import random

arrayLength = 65535
numberOfRAMChunks = 2000 # must be < arrayLength
maxBlocks = 100
maxBufferLength = 30
randomResetProb = 0.2
positions = ["00","01","10","11"]

# variables to be replaced are wrapped in dollar sign

checkEmpty = '''
\tASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
\tASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
\tASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
\tASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 
'''

with open('template','r') as f:
    template = f.read()
    f.close()


# returns a randomly long, sorted array of random valid RAM positions
ramPositions = sorted(random.sample(range(arrayLength), k=random.randint(numberOfRAMChunks/2,numberOfRAMChunks)))
# creates a dict with the aforementioned ram positions and a random 8bit value
RAM = {p:random.randint(0,255) for p in ramPositions}
ramFilling = ''

for p,v in RAM.items():
    ramFilling += f"\t\t\t\t{p} => STD_LOGIC_VECTOR(to_unsigned({v}, 8)),\n"

template = template.replace("$ramFilling$",ramFilling)

# setting the filling value for fallback (unspecified ram indexes)
fallbackValue = random.randint(0,255)
template = template.replace("$fallbackValue$", str(fallbackValue))

# Block = sequence of Reset+ W + Start signal 
# W: 2bit selector + rndBit[1-16] + rndBuffer[0-maxBufferLength]
# R: "0" everywhere, randomly 1 or 0 with a randomResetProb after W
# S: "1" under selector and rndBits and "0" everywhere else

numberOfBlocks = random.randint(1,maxBlocks)

# starts at 5 because of the initial reset already in the template
scenarioLength = 5

w = ''
start = ''
reset = ''

testAsserts = ''

for bn in range(numberOfBlocks):
    pos = random.choice(positions)
    posDec = positions.index(pos)

    scenarioLength += 2

    # to get the memory address i generate a random int, cast to binary
    # and finally reverse it as the W has LSB first
    mem = random.randint(0,arrayLength)
    memValue = RAM.get(mem, fallbackValue)
    memoryAddress = str(bin(mem)).split("0b")[1][::-1]
    
    scenarioLength += len(memoryAddress)

    bufferLength = random.randint(0,maxBufferLength)
    scenarioLength += bufferLength
    buffer = "0" * bufferLength

    resetFlag = "1" if random.random() <= randomResetProb else "0"
    scenarioLength += 1

    w += f"{pos}{memoryAddress}{buffer}0"
    start += f"11{'1' * len(memoryAddress)}{buffer}0"
    reset += f"00{'0' * len(memoryAddress)}{buffer}{resetFlag}"

    testAsserts += "\tWAIT UNTIL tb_start = '1';\n"
    testAsserts += checkEmpty
    testAsserts += "\tWAIT UNTIL tb_done = '1';\n"
    testAsserts += "\tWAIT FOR CLOCK_PERIOD/2;\n"
    testAsserts += f"\tASSERT tb_z{posDec} = std_logic_vector(to_unsigned({memValue}, 8)) severity failure;"
    testAsserts += "\tWAIT UNTIL tb_done = '0';\n"
    testAsserts += "\tWAIT FOR CLOCK_PERIOD/2;\n"
    testAsserts += checkEmpty

assert len(w) == len(start) == len(reset) == (scenarioLength - 5)

template = template.replace("$scenarioW$",w)
template = template.replace("$scenarioStart$",start)
template = template.replace("$scenarioReset$",reset)
template = template.replace("$scenarioLength$",str(scenarioLength))
template = template.replace("$testAsserts$",testAsserts)

with open(f"tests/tb_{random.randint(0,100000000)}.vhd","w") as f:
    f.write(template)
    f.close()































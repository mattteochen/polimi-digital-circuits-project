import os
import random
import argparse
import datetime

parser = argparse.ArgumentParser(
    prog = "TestBench generator - RL23 - PoliMi",
    description = "This script generates testbenches for the Final Project of Digital Logic Design (Reti Logiche) ~ PoliMi - Prof. William Fornaciari - A.Y. 2022-23",
    epilog = "Credits: Francesco Buccoliero - Kaixi Matteo Chen ~ francesco.buccoliero@mail.polimi.it - kaiximatteo.chen@mail.polimi.it"
    )
parser.add_argument("-s", "--seed", dest="seed", type=int, default = random.randint(0,1000000000), help="Seed for the random number generator. Set it to a previously generated TB to recreate the same situation")
parser.add_argument("-a", "--arrayLength", dest="arrayLength", type=int, default=65535, help="Number of 8bit blocks in RAM")
parser.add_argument("-r", "--numberOfRAMChunks", dest="numberOfRAMChunks", type=int, default = 2000, help="Number of 8bit blocks to set to random values")
parser.add_argument("-b", "--maxBlocks", dest="maxBlocks", type=int, default = 100, help = "Maximum number of addresses to read and write in the test")
parser.add_argument("-B", "--maxBufferLength", dest="maxBufferLength", type=int, default = 30, help = "Maximum length of '0' bits after address in W stream")
parser.add_argument("-R", "--randomResetProb", dest="randomResetProb", type=float, default = 0.2, help = "Probability of having a reset after a block. Format: decimal [0,1]")
parser.add_argument("-t", "--TBnum", dest="TBnum", type=int, default = 1, help = "Number of testbenches to generate")

args = parser.parse_args()

seed = args.seed
arrayLength = args.arrayLength
numberOfRAMChunks = args.numberOfRAMChunks
maxBlocks = args.maxBlocks
maxBufferLength = args.maxBufferLength
randomResetProb = args.randomResetProb
TBnum = args.TBnum 

assert numberOfRAMChunks < arrayLength, "numberOfRAMChunks must be less than arrayLength"

positions = ["00","01","10","11"]
folder = datetime.datetime.now().strftime("%y%m%d%H%M%S")

checkEmpty = '''
\tASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
\tASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
\tASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
\tASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 
'''


for _ in range(TBnum):
    with open('tbTemplate','r') as f:
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
    # W: 2bit selector + rndBit[1-16] + rndBuffer[6-maxBufferLength]
    #   assuming 6 as minimum Buffer length to allow the shortest cycle to
    #   end and set up done to 1 and back to 0 before restarting 
    # R: "0" everywhere, randomly 1 or 0 with a randomResetProb after W
    # S: "1" under selector and rndBits and "0" everywhere else

    numberOfBlocks = random.randint(1,maxBlocks)

    # starts at 5 because of the initial reset already in the template
    scenarioLength = 5

    w = ''
    start = ''
    reset = ''

    testAsserts = ''

    memValues = [0,0,0,0]

    for bn in range(numberOfBlocks):
        pos = random.choice(positions)
        posDec = positions.index(pos)

        scenarioLength += 2

        # to get the memory address i generate a random int, cast to binary
        # and finally reverse it as the W has LSB first
        mem = random.randint(0,arrayLength)
        memValue = RAM.get(mem, fallbackValue)
        memoryAddress = str(bin(mem)).split("0b")[1][::-1]

        memValues[posDec] = memValue
        
        scenarioLength += len(memoryAddress)

        bufferLength = random.randint(6,maxBufferLength)
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
        for i in range(4):
            testAsserts += f"\tASSERT tb_z{i} = std_logic_vector(to_unsigned({memvalues[i]}, 8)) severity failure; -- {posDec == i ? "UPDATED" : "NOT UPDATED"} \n"    
        testAsserts += "\tWAIT UNTIL tb_done = '0';\n"
        testAsserts += "\tWAIT FOR CLOCK_PERIOD/2;\n"
        testAsserts += checkEmpty
        if resetFlag == "1":
            memValues = [0,0,0,0]

    assert len(w) == len(start) == len(reset) == (scenarioLength - 5), "Length of streams not matching"
    
    template = template.replace("$arrayLength$",str(arrayLength))
    template = template.replace("$scenarioW$",w)
    template = template.replace("$scenarioStart$",start)
    template = template.replace("$scenarioReset$",reset)
    template = template.replace("$scenarioLength$",str(scenarioLength))
    template = template.replace("$testAsserts$",testAsserts)

    assert template.count('->') == start.count('10'), "Number of asserts not matching number of start blocks"

    os.makedirs(f"tests/{folder}", exist_ok=True)
    with open(f"tests/{folder}/tb_{seed}.vhd","w") as f:
        f.write(template)
        f.close()































import random

arrayLength = 65535
numberOfRAMChunks = 100 # must be < arrayLength
maxBlocks = 100
maxBufferLength = 30
randomResetProb = 0.2

# variables to be replaced are wrapped in dollar sign
template = '''
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;

ENTITY project_tb IS
END project_tb;

ARCHITECTURE projecttb OF project_tb IS
    CONSTANT CLOCK_PERIOD : TIME := 100 ns;
    SIGNAL tb_done : STD_LOGIC;
    SIGNAL mem_address : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_rst : STD_LOGIC := '0';
    SIGNAL tb_start : STD_LOGIC := '0';
    SIGNAL tb_clk : STD_LOGIC := '0';
    SIGNAL mem_o_data, mem_i_data : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL enable_wire : STD_LOGIC;
    SIGNAL mem_we : STD_LOGIC;
    SIGNAL tb_z0, tb_z1, tb_z2, tb_z3 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL tb_w : STD_LOGIC;

    CONSTANT SCENARIOLENGTH : INTEGER := $scenarioLength$; 
    SIGNAL scenario_rst : unsigned(0 TO SCENARIOLENGTH - 1)     := "00110" & "$scenarioReset$";
    SIGNAL scenario_start : unsigned(0 TO SCENARIOLENGTH - 1)   := "00000" & "$scenarioStart$";
    SIGNAL scenario_w : unsigned(0 TO SCENARIOLENGTH - 1)       := "00000" & "$scenarioW$";

    TYPE ram_type IS ARRAY (65535 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL RAM : ram_type := (  
$ramFilling$
                                OTHERS => STD_LOGIC_VECTOR(to_unsigned($fallbackValue$, 8)
                            );
                    
    COMPONENT project_reti_logiche IS
        PORT (
            i_clk : IN STD_LOGIC;
            i_rst : IN STD_LOGIC;
            i_start : IN STD_LOGIC;
            i_w : IN STD_LOGIC;

            o_z0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_z1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_z2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_z3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_done : OUT STD_LOGIC;

            o_mem_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            i_mem_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_mem_we : OUT STD_LOGIC;
            o_mem_en : OUT STD_LOGIC
        );
    END COMPONENT project_reti_logiche;

BEGIN
    UUT : project_reti_logiche
    PORT MAP(
        i_clk => tb_clk,
        i_start => tb_start,
        i_rst => tb_rst,
        i_w => tb_w,

        o_z0 => tb_z0,
        o_z1 => tb_z1,
        o_z2 => tb_z2,
        o_z3 => tb_z3,
        o_done => tb_done,

        o_mem_addr => mem_address,
        o_mem_en => enable_wire,
        o_mem_we => mem_we,
        i_mem_data => mem_o_data
    );


    -- Process for the clock generation
    CLK_GEN : PROCESS IS
    BEGIN
        WAIT FOR CLOCK_PERIOD/2;
        tb_clk <= NOT tb_clk;
    END PROCESS CLK_GEN;


    -- Process related to the memory
    MEM : PROCESS (tb_clk)
    BEGIN
        IF tb_clk'event AND tb_clk = '1' THEN
            IF enable_wire = '1' THEN
                IF mem_we = '1' THEN
                    RAM(conv_integer(mem_address)) <= mem_i_data;
                    mem_o_data <= mem_i_data AFTER 1 ns;
                ELSE
                    mem_o_data <= RAM(conv_integer(mem_address)) AFTER 1 ns; 
                END IF;
                ASSERT (mem_we = '1' OR mem_we = '0') REPORT "o_mem_we in an unexpected state" SEVERITY failure;
            END IF;
            ASSERT (enable_wire = '1' OR enable_wire = '0') REPORT "o_mem_en in an unexpected state" SEVERITY failure;
        END IF;
    END PROCESS;
    
    -- This process provides the correct scenario on the signal controlled by the TB
    createScenario : PROCESS (tb_clk)
    BEGIN
        IF tb_clk'event AND tb_clk = '0' THEN
            tb_rst <= scenario_rst(0);
            tb_w <= scenario_w(0);
            tb_start <= scenario_start(0);
            scenario_rst <= scenario_rst(1 TO SCENARIOLENGTH - 1) & '0';
            scenario_w <= scenario_w(1 TO SCENARIOLENGTH - 1) & '0';
            scenario_start <= scenario_start(1 TO SCENARIOLENGTH - 1) & '0';
        END IF;
    END PROCESS;

    -- Process without sensitivity list designed to test the actual component.
    testRoutine : PROCESS IS
    BEGIN
        mem_i_data <= "00000000";

        WAIT UNTIL tb_rst = '1';
        WAIT UNTIL tb_rst = '0';

        ASSERT tb_done = '0' REPORT "TEST FALLITO (postreset DONE != 0 )" SEVERITY failure;
        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 
        WAIT UNTIL tb_start = '1';
        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (poststart Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (poststart Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (poststart Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (poststart Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 
        WAIT UNTIL tb_done = '1';

        WAIT FOR CLOCK_PERIOD/2;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(162, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        WAIT UNTIL tb_done = '0';
        WAIT FOR CLOCK_PERIOD/2;
        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postdone Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postdone Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postdone Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postdone Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 
        WAIT UNTIL tb_start = '1';
        WAIT UNTIL tb_done = '1';
        
        WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z1 = std_logic_vector(to_unsigned(88, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(162, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;

        ASSERT false REPORT "Simulation Ended! TEST PASSATO (EXAMPLE)" SEVERITY failure;
    END PROCESS testRoutine;

END projecttb;
'''

# returns a randomly long, sorted array of random valid RAM positions
ramPositions = sorted(random.sample(range(arrayLength), k=random.randint(1,numberOfRAMChunks)))
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

for bn in range(numberOfBlocks):
    pos = random.choice(["00","01","10","11"])
    scenarioLength += 2

    # to get the memory address i generate a random int, cast to binary
    # and finally reverse it as the W has LSB first
    memoryAddress = str(bin(random.randint(0,arrayLength))).split("0b")[1][::-1]
    scenarioLength += len(memoryAddress)

    bufferLength = random.randint(0,maxBufferLength)
    scenarioLength += bufferLength
    buffer = "0" * bufferLength

    resetFlag = "1" if random.random() <= randomResetProb else "0"
    scenarioLength += 1

    w += f"{pos}{memoryAddress}{buffer}0"
    start += f"11{'1' * len(memoryAddress)}{buffer}0"
    reset += f"00{'0' * len(memoryAddress)}{buffer}{resetFlag}"

assert len(w) == len(start) == len(reset) == (scenarioLength - 5)

template = template.replace("$scenarioW$",w)
template = template.replace("$scenarioStart$",start)
template = template.replace("$scenarioReset$",reset)
template = template.replace("$scenarioLength$",str(scenarioLength))
    
print(template)
































library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity square is
    Port ( i_clk : in STD_LOGIC;    --input from outside
           i_res : in STD_LOGIC;    --input from outside
           i_start : in std_logic;  --input from outside
           i_w : in std_logic;      --input from outside
           
           o_done : out STD_LOGIC;  --this output is generated from square state machine, it is not dependent on the datapath
           o_z0 : out std_logic_vector(15 downto 0);        --this output is generated from the datapath
           o_z1 : out std_logic_vector(15 downto 0);        --this output is generated from the datapath
           o_z2 : out std_logic_vector(15 downto 0);        --this output is generated from the datapath
           o_z3 : out std_logic_vector(15 downto 0);        --this output is generated from the datapath
           o_selector : out std_logic_vector(1 downto 0);   --this output is generated from the datapath
           o_memory : out std_logic_vector(15 downto 0);    --this output is generated from the datapath
           o_counter : out STD_LOGIC_VECTOR (7 downto 0));  --this output is generated from the datapath
end square;

architecture Behavioral of square is
component datapath is
    Port ( i_clk : in STD_LOGIC;
           i_res : in STD_LOGIC;
           r_load : in STD_LOGIC;
           i_start : in std_logic;
           i_w : in std_logic;
           i_show : in std_logic;
           
           o_z0 : out std_logic_vector(15 downto 0);
           o_z1 : out std_logic_vector(15 downto 0);
           o_z2 : out std_logic_vector(15 downto 0);
           o_z3 : out std_logic_vector(15 downto 0);
           o_selctor : out std_logic_vector(1 downto 0); -- the test out selector
           o_memory : out std_logic_vector(15 downto 0); --the test memory buffer
           o_counter : out std_logic_vector(7 downto 0); --the sum result
           o_end : out STD_LOGIC --signal the end of the operation
     );
end component;
signal i_load : STD_LOGIC;
signal o_end : STD_LOGIC;
signal i_show : std_logic;
type S is (S0,S1);
signal cur_state, next_state : S;
begin
    DATAPATH0: datapath port map(
        i_clk,
        i_res,
        i_load,
        i_start,
        i_w,
        i_show,
        o_z0,
        o_z1,
        o_z2,
        o_z3,
        o_selector,
        o_memory,
        o_counter,
        o_end
    );
    
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, o_end)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                if o_end = '1' then
                    next_state <= S1;
                end if;
            when S1 =>
                next_state <= S0;
        end case;
    end process;
    
    process(cur_state)
    begin
        i_load <= '0';
        o_done <= '0';
        i_show <= '0';
        case cur_state is
            when S0 =>
                i_load <= '1';
            when S1 =>
                i_load <= '1';
                i_show <= '1';
                o_done <= '1';
        end case;
    end process;
    
end Behavioral;

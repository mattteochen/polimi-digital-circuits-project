library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity square is
    Port(i_clk : in std_logic;
         i_res : in std_logic;
         i_start : in std_logic;
         i_sel : in std_logic_vector (1 downto 0);
         i_memout : in std_logic_vector (7 downto 0);           
         o_z0 : out std_logic_vector(7 downto 0);
         o_z1 : out std_logic_vector(7 downto 0); 
         o_z2 : out std_logic_vector(7 downto 0); 
         o_z3 : out std_logic_vector(7 downto 0); 
         o_done : out std_logic);     
end square;

architecture Behavioral of square is
component datapath is
    Port ( i_clk : in STD_LOGIC;
           i_res : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_show : in STD_LOGIC;
           i_sel : in std_logic_vector (1 downto 0);
           i_memout : in STD_LOGIC_VECTOR (7 downto 0);
           z0_load : in STD_LOGIC;
           z1_load : in STD_LOGIC;
           z2_load : in STD_LOGIC;
           z3_load : in STD_LOGIC;
           --o_done : out std_logic;
           o_z0 : out STD_LOGIC_VECTOR (7 downto 0);
           o_z1 : out STD_LOGIC_VECTOR (7 downto 0);
           o_z2 : out STD_LOGIC_VECTOR (7 downto 0);
           o_z3 : out STD_LOGIC_VECTOR (7 downto 0));
end component;
signal z0_load : STD_LOGIC;
signal z1_load : STD_LOGIC;
signal z2_load : STD_LOGIC;
signal z3_load : STD_LOGIC;
signal i_show : STD_LOGIC;


type S is (S0,S1,S2);
signal cur_state, next_state : S;
begin
    DATAPATH0: datapath port map(
        i_clk,
        i_res,
        i_start,
        i_show,
        i_sel,
        i_memout,
        z0_load,
        z1_load,
        z2_load,
        z3_load,
        --o_done,
        o_z0,
        o_z1,
        o_z2,
        o_z3
    );
    
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_start)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                --if i_start = '1' then
                    next_state <= S1;
                --end if;
            when S1 =>
                next_state <= S2;
            when S2 =>
                next_state <= S0;
        end case;
    end process;
    
    process(cur_state)
    begin
        z0_load <= '0';
        z1_load <= '0';
        z2_load <= '0';
        z3_load <= '0';
        o_done <= '0';
        i_show <= '0';
        case cur_state is
            when S0 =>
            when S1 =>
                z0_load <= '1';
                z1_load <= '1';
                z2_load <= '1';
                z3_load <= '1';
            when S2 =>
                i_show <= '1';
                o_done <= '1';
        end case;
    end process;
    
end Behavioral;

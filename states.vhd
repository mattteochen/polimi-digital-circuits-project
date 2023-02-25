library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_start : in std_logic;
           i_w : in std_logic;
           
           o_z0 : out std_logic_vector(7 downto 0);        --this output is generated from the datapath
           o_z1 : out std_logic_vector(7 downto 0);        --this output is generated from the datapath
           o_z2 : out std_logic_vector(7 downto 0);        --this output is generated from the datapath
           o_z3 : out std_logic_vector(7 downto 0);        --this output is generated from the datapath
           o_done : out STD_LOGIC;
           
           o_mem_addr : out std_logic_vector(15 downto 0);  --this output is generated from the datapath
           i_mem_data : in std_logic_vector(7 downto 0);
           o_mem_we : out std_logic;
           o_mem_en : out std_logic);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component datapath is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_start : in std_logic;
           i_w : in std_logic;
           i_show : in std_logic;
           i_z0_load : in std_logic;
           i_z1_load : in std_logic;
           i_z2_load : in std_logic;
           i_z3_load : in std_logic;
           i_mem_data : in std_logic_vector(7 downto 0);
           
           o_z0 : out std_logic_vector(7 downto 0);
           o_z1 : out std_logic_vector(7 downto 0);
           o_z2 : out std_logic_vector(7 downto 0);
           o_z3 : out std_logic_vector(7 downto 0);
           o_mem_addr : out std_logic_vector(15 downto 0)
     );
end component;

signal i_show : std_logic;
signal i_z0_load : std_logic;
signal i_z1_load : std_logic;
signal i_z2_load : std_logic;
signal i_z3_load : std_logic;

type S is (S0,S1,S2,S3,S4,S5);
signal cur_state, next_state : S;

begin
    DATAPATH0: datapath port map(
        i_clk,
        i_rst,
        i_start,
        i_w,
        i_show,
        i_z0_load,
        i_z1_load,
        i_z2_load,
        i_z3_load,
        i_mem_data,
        o_z0,
        o_z1,
        o_z2,
        o_z3,
        o_mem_addr
    );
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
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
                if i_start = '1' then
                    next_state <= S1;
                end if;
            when S1 =>
                if i_start = '0' then
                    next_state <= S2;
                end if;
            when S2 =>
                next_state <= S3;
            when S3 =>
                next_state <= S4;
            when S4 =>
                next_state <= S5;
            when S5 =>
                if i_start = '1' then
                    next_state <= S1;
                else
                    next_state <= S0; 
                end if;
        end case;
    end process;
    
    process(cur_state)
    begin
        o_mem_we <= '0';
        o_mem_en <= '0';
        o_done <= '0';
        i_show <= '0';
        i_z0_load <= '0';
        i_z1_load <= '0';
        i_z2_load <= '0';
        i_z3_load <= '0';
        case cur_state is
            when S0 =>
            when S1 =>
            when S2 =>
                o_mem_en <= '1';
            when S3 =>
                o_mem_en <= '1';
            when S4 =>
                i_z0_load <= '1';
                i_z1_load <= '1';
                i_z2_load <= '1';
                i_z3_load <= '1';    
            when S5 =>
                i_show <= '1';
                o_done <= '1';
        end case;
    end process;
    
end Behavioral;

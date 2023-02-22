
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity datapath is
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
end datapath;

architecture Behavioral of datapath is
signal o_reg_z0 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg_z1 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg_z2 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg_z3 : STD_LOGIC_VECTOR (7 downto 0);

signal mux_z0 : STD_LOGIC_VECTOR (7 downto 0);
signal mux_z1 : STD_LOGIC_VECTOR (7 downto 0);
signal mux_z2 : STD_LOGIC_VECTOR (7 downto 0);
signal mux_z3 : STD_LOGIC_VECTOR (7 downto 0);
-- signal mux_done : std_logic;


signal demux : STD_LOGIC_VECTOR (7 downto 0);
begin
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_reg_z0 <= "00000000";
            o_reg_z1 <= "00000000";
            o_reg_z2 <= "00000000";
            o_reg_z3 <= "00000000";
        elsif (i_clk'event and i_clk = '1') then
            case i_sel is
                when "00" =>
                    if (z0_load = '1') then
                        o_reg_z0 <= i_memout;
                    end if;
                when "01" =>
                    if (z1_load = '1') then
                        o_reg_z1 <= i_memout;
                    end if;               
                when "10" =>
                    if (z2_load = '1') then
                        o_reg_z2 <= i_memout;
                    end if;                
                when "11" =>
                    if (z3_load = '1') then
                        o_reg_z3 <= i_memout;
                    end if;
                when others =>
            end case;
        end if;
    end process;
        
    with i_show select
        mux_z0 <= "00000000" when '0',
                   o_reg_z0 when '1',
                    "XXXXXXXX" when others;
                    
    with i_show select
        mux_z1 <= "00000000" when '0',
                   o_reg_z1 when '1',
                    "XXXXXXXX" when others;
                    
    with i_show select
        mux_z2 <= "00000000" when '0',
                   o_reg_z2 when '1',
                    "XXXXXXXX" when others;
                    
    with i_show select
        mux_z3 <= "00000000" when '0',
                   o_reg_z3 when '1',
                    "XXXXXXXX" when others;
    
    o_z0 <= mux_z0;
    o_z1 <= mux_z1;
    o_z2 <= mux_z2;
    o_z3 <= mux_z3;
end Behavioral;


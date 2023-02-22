library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
    Port ( i_clk : in STD_LOGIC;
           i_res : in STD_LOGIC;
           r_load : in STD_LOGIC;
           i_w : in std_logic;
           
           o_memory : out std_logic_vector(15 downto 0); --the test memory buffer
           o_counter : out std_logic_vector(7 downto 0); --the sum result
           o_end : out STD_LOGIC --signal the end of the sum operation
     );
end datapath;


architecture Behavioral of datapath is

signal sum : STD_LOGIC_VECTOR(7 downto 0);
signal o_reg : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg_mem : STD_LOGIC_VECTOR (15 downto 0);

begin    
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_reg <= "00000000";
            o_reg_mem <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r_load = '1') then
                o_reg <= sum;
                o_reg_mem(to_integer(unsigned(o_reg))) <= i_w;
            end if;
        end if;
    end process;
    
    sum <= o_reg + "00000001";
    
    o_counter <= o_reg;
    o_memory <= o_reg_mem;
    o_end <= '1' when (o_reg = "00001000") else '0';

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
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
end datapath;


architecture Behavioral of datapath is

signal sum : STD_LOGIC_VECTOR(7 downto 0);
signal o_reg : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg_mem : STD_LOGIC_VECTOR (15 downto 0);
signal o_reg_selector : std_logic_vector(1 downto 0);
signal o_reg_z0 : STD_LOGIC_VECTOR (15 downto 0);
signal o_reg_z1 : STD_LOGIC_VECTOR (15 downto 0);
signal o_reg_z2 : STD_LOGIC_VECTOR (15 downto 0);
signal o_reg_z3 : STD_LOGIC_VECTOR (15 downto 0);
signal o_mux_z0 : STD_LOGIC_VECTOR (15 downto 0);
signal o_mux_z1 : STD_LOGIC_VECTOR (15 downto 0);
signal o_mux_z2 : STD_LOGIC_VECTOR (15 downto 0);
signal o_mux_z3 : STD_LOGIC_VECTOR (15 downto 0);

signal maintain_low_one_cycle : std_logic_vector(7 downto 0);
signal start_sequence_entered : std_logic;

begin    
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
        
            o_reg <= "00000000";
            o_reg_mem <= "0000000000000000";
            o_reg_selector <= "00";
            o_reg_z0 <= "0000000000000000";
            o_reg_z1 <= "0000000000000000";
            o_reg_z2 <= "0000000000000000";
            o_reg_z3 <= "0000000000000000";
            start_sequence_entered <= '0';
            maintain_low_one_cycle <= "00000000"; --true
            o_mux_z0 <= "0000000000000000";
            o_mux_z1 <= "0000000000000000";
            o_mux_z2 <= "0000000000000000";
            o_mux_z3 <= "0000000000000000";
            
        elsif i_clk'event and i_clk = '1' then
        
            if r_load = '1' and i_start = '1' then
                
                --reset memory register if first bit of the valid sequence, we can leave selector register as is as it will be overwritten
                if start_sequence_entered = '0' then
                    o_reg_mem <= "0000000000000000";
                    o_reg_selector <= "00";
                end if;
                
                o_reg <= sum;
                start_sequence_entered <= '1';
                maintain_low_one_cycle <= "11111111"; --false
                
                --save the selector bits
                if o_reg = "00000000" then
                    o_reg_selector(1) <= i_w;
                elsif o_reg = "00000001" then
                    o_reg_selector(0) <= i_w;
                --after the selector, save the 16(max) bits of the memory
                else
                    --setting to the Ith index of the vector to i_w. The position is deducted by
                    --  two as the first two counts have been reserved to the selector computation
                    o_reg_mem(to_integer(unsigned(o_reg - "00000010"))) <= i_w;
                end if;
                
                --set the END value
                o_end <= '0';
                
            elsif i_start = '0' then
            
                if o_reg_selector = "11" then
                    o_reg_z0 <= o_reg_mem;
                end if;
                --fill others...
                
                o_reg <= "00000000";
                maintain_low_one_cycle <= "00000000"; --true
                
                --if a start seq has been started and ended, we have finished the computation (memory TBD), hence we signal END=1 and reset this flag
                if start_sequence_entered = '1' then
                    o_end <= '1';
                    start_sequence_entered <= '0';
                --otherwise it may be the first zeros in the sequence, keep END=0
                else
                    o_end <= '0';
                end if;
                
            end if;
            
        end if;
    end process;
    
    sum <= o_reg + ("00000001" and maintain_low_one_cycle); --if i_start is low, sum is constant!
    
    o_counter <= o_reg;
    o_memory <= o_reg_mem;
    o_selctor <= o_reg_selector;
        
    o_z0 <= o_reg_z0 when(i_show = '1') else "0000000000000000";
    o_z1 <= o_reg_z1 when(i_show = '1') else "0000000000000000";
    o_z2 <= o_reg_z2 when(i_show = '1') else "0000000000000000";
    o_z3 <= o_reg_z3 when(i_show = '1') else "0000000000000000";
    
end Behavioral;

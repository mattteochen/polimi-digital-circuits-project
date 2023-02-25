library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_1164.all;

entity datapath is
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
end datapath;


architecture Behavioral of datapath is

signal sum : STD_LOGIC_VECTOR(4 downto 0);
signal o_reg_sum : STD_LOGIC_VECTOR (4 downto 0);
signal o_reg_mem_addr : STD_LOGIC_VECTOR (15 downto 0);
signal o_reg_adj_mem_addr : std_logic_vector(15 downto 0);
signal o_reg_selector : std_logic_vector(1 downto 0);
signal o_reg_z0 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg_z1 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg_z2 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg_z3 : STD_LOGIC_VECTOR (7 downto 0);
--needed to reset the memory_addr buffer when entering a new start sequence coming from a START=0 sequence.
--needed to raise the end flag as it signals the transition from the last 1 bit of a START=1 sequence to the first 0 bit of a START=0 sequence.
signal start_sequence_entered : std_logic;

begin    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
        
            o_reg_sum <= "00000";
            o_reg_mem_addr <= "0000000000000000";
            o_reg_adj_mem_addr <= "0000000000000000";
            o_reg_selector <= "00";
            o_reg_z0 <= "00000000";
            o_reg_z1 <= "00000000";
            o_reg_z2 <= "00000000";
            o_reg_z3 <= "00000000";
            start_sequence_entered <= '0';
            
        elsif i_clk'event and i_clk = '1' then
        
            --if r_load = '1' and i_start = '1' then
            if i_start = '1' then
                            
                --reset memory register if first bit of the valid sequence, (we can leave selector register as is as it will be always overwritten)
                if start_sequence_entered = '0' then
                    o_reg_mem_addr <= "0000000000000000";
                    o_reg_adj_mem_addr <= "0000000000000000";
                    --o_reg_selector <= "00";
                end if;
                
                --assign to the sum register the previous sum operation result
                o_reg_sum <= sum;
                
                --raise the sequence entering flag
                start_sequence_entered <= '1';
                
                --save the selector bits if the sum inside its reg is < 2
                if o_reg_sum = "00000" then
                    o_reg_selector(1) <= i_w;
                elsif o_reg_sum = "00001" then
                    o_reg_selector(0) <= i_w;
                --after the selector, save the 16(max) bits of the memory (reg_sum >= 2)
                else
                    --setting to the Ith index of the vector to i_w. The position is deducted by
                    --  two as the first two counts have been reserved to the selector computation
                    o_reg_mem_addr(to_integer(unsigned(o_reg_sum - "00010"))) <= i_w;
                end if;
                
            else
                --after the START=1 sequence, create the swapped memory_address
                --here we are subtracting 0x3 and not 0x2 from the sum register value as a clock cycle has passed from the correct index pointed out from the sum register value itself
                if start_sequence_entered = '1' then
                    for i in 0 to to_integer(unsigned(o_reg_sum - "00011"))
                    loop
                        o_reg_adj_mem_addr(to_integer(unsigned(o_reg_sum - "00011"))-i) <= o_reg_mem_addr(i);
                    end loop;
                end if;
            
                --the read flag is down (START=0), don't read more bits from W. Mirror the memory value to the output channel based on the selector value.
                if o_reg_selector = "00" and i_z0_load = '1' then
                    o_reg_z0 <= i_mem_data;  
                elsif o_reg_selector = "01" and i_z1_load = '1' then
                    o_reg_z1 <= i_mem_data;
                elsif o_reg_selector = "10" and i_z2_load = '1' then
                    o_reg_z2 <= i_mem_data;
                elsif o_reg_selector = "11"  and i_z3_load = '1'then
                    o_reg_z3 <= i_mem_data; 
                end if;
                
                --reset counter reg for the next cycle.
                o_reg_sum <= "00000";
                
                --if a start sequence has been started and is ended, we have finished the computation
                if start_sequence_entered = '1' then
                    start_sequence_entered <= '0';
                end if;
              
            end if;
        end if;
    end process;
    
    sum <= o_reg_sum + "00001"; --if i_start is low, sum is constant!
    
    --assign the correct (swapped) memory address
    o_mem_addr <= o_reg_adj_mem_addr;
    
    --apply the mux mask to the output channels
    o_z0 <= o_reg_z0 when(i_show = '1') else "00000000";
    o_z1 <= o_reg_z1 when(i_show = '1') else "00000000";
    o_z2 <= o_reg_z2 when(i_show = '1') else "00000000";
    o_z3 <= o_reg_z3 when(i_show = '1') else "00000000";
    
end Behavioral;

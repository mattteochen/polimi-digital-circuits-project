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
           i_update_mem_addr : in std_logic;
           i_reset_mem : in std_logic;
           
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
signal i_update_mem_addr : std_logic;
signal i_reset_mem : std_logic;

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
        i_update_mem_addr,
        i_reset_mem,
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
        i_update_mem_addr <= '0';
        i_reset_mem <= '0';
        
        case cur_state is
            when S0 =>
                i_reset_mem <= '1';
            when S1 =>
                i_update_mem_addr <= '1';
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

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
           i_update_mem_addr : in std_logic;
           i_reset_mem : in std_logic;
           
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
            
        elsif i_clk'event and i_clk = '1' then
        
            --if r_load = '1' and i_start = '1' then
            if i_start = '1' then
                
                --assign to the sum register the previous sum operation result
                o_reg_sum <= sum;
                
                --raise the sequence entering flag
                --start_sequence_entered <= '1';
                
                --save the selector bits if the sum inside its reg is < 2
                if o_reg_sum = "00000" then
                    o_reg_selector(1) <= i_w;
                elsif o_reg_sum = "00001" then
                    o_reg_selector(0) <= i_w;
                --after the selector, save the 16(max) bits of the memory (reg_sum >= 2)
                else
                    --start the buffer write from the MSB (17 - reg_sum(>=2) = 15). No overflow check as given from the tb.
                    o_reg_mem_addr(17 - to_integer(unsigned(o_reg_sum))) <= i_w;
                end if;
            else
                o_reg_sum <= "00000";
            end if;
                --some bits manipulation: after the START=1 sequence, create the adjusted memory_address by logic shift the buffer bits to the right by the formula: [15 - (current_counter -3)]
                --note that the current counter has incremented by one from the last START=1 signal clock cycle, the "minus 3 magic" comes from here (see the written report for more)
                if i_update_mem_addr = '1' then
                    o_reg_adj_mem_addr <= std_logic_vector(unsigned(o_reg_mem_addr) srl (15 - (to_integer(unsigned(o_reg_sum)) - 3)));
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
        
            --reset memory register if first bit of the valid sequence, (we can leave selector register as is as it will be always overwritten)
            if i_reset_mem = '1' then
                o_reg_mem_addr <= "0000000000000000";
                o_reg_adj_mem_addr <= "0000000000000000";
                --o_reg_selector <= "00";
            end if;
        end if;
    end process;
    
    sum <= o_reg_sum + "00001"; --if i_start is low, sum is constant!
    
    --assign the correct (shifted) memory address
    o_mem_addr <= o_reg_adj_mem_addr;
    
    --apply the mux mask to the output channels
    o_z0 <= o_reg_z0 when(i_show = '1') else "00000000";
    o_z1 <= o_reg_z1 when(i_show = '1') else "00000000";
    o_z2 <= o_reg_z2 when(i_show = '1') else "00000000";
    o_z3 <= o_reg_z3 when(i_show = '1') else "00000000";
    
end Behavioral;

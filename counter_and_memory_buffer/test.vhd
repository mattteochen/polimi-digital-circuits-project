
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity square_tb is
--  Port ( );
end square_tb;

architecture Behavioral of square_tb is
component square is
    Port ( i_clk : in STD_LOGIC;
           i_res : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_w : in STD_LOGIC;
           o_done : out STD_LOGIC;
           o_z0 : out std_logic_vector(15 downto 0);
           o_z1 : out std_logic_vector(15 downto 0);
           o_z2 : out std_logic_vector(15 downto 0);
           o_z3 : out std_logic_vector(15 downto 0);
           o_selector : out std_logic_vector(1 downto 0);
           o_memory : out std_logic_vector(15 downto 0);
           o_counter : out STD_LOGIC_VECTOR (7 downto 0));
end component;
signal i_clk : STD_LOGIC;
signal i_res : STD_LOGIC;
signal i_start : STD_LOGIC;
signal i_w : STD_LOGIC;
signal o_done : STD_LOGIC;
signal o_counter : STD_LOGIC_VECTOR (7 downto 0);
signal o_memory : STD_LOGIC_VECTOR (15 downto 0);
signal o_z1 : STD_LOGIC_VECTOR (15 downto 0);
signal o_z2 : STD_LOGIC_VECTOR (15 downto 0);
signal o_z3 : STD_LOGIC_VECTOR (15 downto 0);
signal o_z0 : STD_LOGIC_VECTOR (15 downto 0);
signal o_selector : STD_LOGIC_VECTOR (1 downto 0);

begin
    TOP0 : square port map(
        i_clk,
        i_res,
        i_start,
        i_w,
        o_done,
        o_z0,
        o_z1,
        o_z2,
        o_z3,
        o_selector,
        o_memory,
        o_counter
    );
    
    i_w <= '1';
        
    process
    begin
        i_clk <= '1';
        wait for 10 ns;
        i_clk <= '0';
        wait for 10 ns;
    end process;
    
    process
    begin
        i_start <= '0';
        i_res <= '1';
        wait for 20 ns;
        i_start <= '1';
        i_res <= '0';
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        i_start <= '0';
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        i_start <= '1';
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        assert false report "simulation ended" severity failure;
    end process;

end Behavioral;

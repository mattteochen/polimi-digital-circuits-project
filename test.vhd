library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity square_tb is
--  Port ( );
end square_tb;

architecture Behavioral of square_tb is
component square is
    Port(i_clk : in std_logic;
         i_res : in std_logic;
         i_start : in std_logic;
         i_sel : in std_logic_vector (1 downto 0);
         i_memout : in std_logic_vector (7 downto 0);
         --i_w : in std_logic;
           
         o_z0 : out std_logic_vector(7 downto 0);
         o_z1 : out std_logic_vector(7 downto 0); 
         o_z2 : out std_logic_vector(7 downto 0); 
         o_z3 : out std_logic_vector(7 downto 0); 
         o_done : out std_logic);     
end component;
signal i_clk : std_logic;
signal i_res : std_logic;
signal i_start : std_logic;
signal i_sel : std_logic_vector (1 downto 0);
signal i_memout : std_logic_vector (7 downto 0);
--i_w : std_logic;
 
signal o_z0 : std_logic_vector(7 downto 0);
signal o_z1 : std_logic_vector(7 downto 0); 
signal o_z2 : std_logic_vector(7 downto 0); 
signal o_z3 : std_logic_vector(7 downto 0); 
signal o_done : std_logic;

begin
    TOP0 : square port map(
        i_clk,
        i_res,
        i_start,
        i_sel,
        i_memout,
        o_z0,
        o_z1,
        o_z2,
        o_z3,
        o_done
    );
    
    --i_sel <= "00";
    --i_memout <= "10101010";
    
    process
    begin
        wait for 10 ns;
        i_clk <= '1';
        wait for 10 ns;
        i_clk <= '0';
    end process;
    
    process
    begin
        i_sel <= "00";
        i_memout <= "10000000";
        i_start <= '0';
        i_res <= '1';
        wait for 10 ns;
        i_res <= '0';
        wait for 20 ns;
        i_start <= '1';
        wait for 20 ns;
        i_start <= '0';
        
        i_sel <= "01";
        i_memout <= "00000001";
        wait for 60 ns;
        i_res <= '1';
        wait for 20 ns;
        i_res <= '0';
        i_sel <= "10";
        i_memout <= "00000010";
        wait for 200 ns;
        assert false report "simulation ended" severity failure;
    end process;

end Behavioral;

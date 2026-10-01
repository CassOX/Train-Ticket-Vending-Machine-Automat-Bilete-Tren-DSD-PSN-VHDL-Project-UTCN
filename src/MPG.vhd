library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MPG is
    PORT ( 
        btn : in STD_LOGIC;
        clk : in STD_LOGIC;
        en  : out std_logic
    );
end MPG;
 
architecture Behavioral of MPG is

    signal count    : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal t        : STD_LOGIC;
    signal q1       : STD_LOGIC;
    signal q2       : STD_LOGIC;
    signal q3       : STD_LOGIC;
    
begin
 
    process (clk)
    begin
    
        if (rising_edge(clk)) then
            count <= count + 1;
        end if;
        
    end process;
     
    t <= '1' when count = x"FFFF" else '0';
     
    process(clk)
    begin
    
        if (rising_edge(clk)) then
            if(t = '1') then
                q1 <= btn;
            end if;
        end if;
        
    end process;
     
    process(clk)
    begin
    
        if (rising_edge(clk)) then
            q2 <= q1;
        q3 <= q2;
        end if;
        
    end process;
     
    en <= q2 and not q3;
 
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bcd_converter is

    PORT (
        binary_in   : in STD_LOGIC_VECTOR (15 downto 0);
        bcd_out     : out STD_LOGIC_VECTOR (15 downto 0)
    );

end bcd_converter;

architecture Behavioral of bcd_converter is
begin

    process (binary_in)
    
        variable temp_binary    : unsigned (15 downto 0);
        variable bcd            : unsigned (15 downto 0);
        
    begin
    
            temp_binary := unsigned(binary_in);
            bcd         := (others => '0');
            
            for i in 0 to 15 loop
                -- if the bcd digit is > 4 then add 3 before we shift
                if bcd(3 downto 0) > 4 then
                    bcd(3 downto 0) := bcd(3 downto 0) + 3;
                end if;
                
                if bcd(7 downto 4) > 4 then
                    bcd(7 downto 4) := bcd(7 downto 4) + 3;
                end if;
                
                if bcd(11 downto 8) > 4 then
                    bcd(11 downto 8) := bcd(11 downto 8) + 3;
                end if;
                
                if bcd(15 downto 12) > 4 then
                    bcd(15 downto 12) := bcd(15 downto 12) + 3;
                end if;
                --left shifting
                bcd         := bcd(14 downto 0) & temp_binary(15);
                temp_binary := temp_binary(14 downto 0) & '0';
                
            end loop;  
             
            bcd_out <= std_logic_vector(bcd);
        
    end process;

end Behavioral;

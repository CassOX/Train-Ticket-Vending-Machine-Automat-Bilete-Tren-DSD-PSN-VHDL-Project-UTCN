library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity distance_and_price_unit is

    PORT (
        clk             : in STD_LOGIC;
        clear_all       : in STD_LOGIC; --triggers by cancel_btn or reset_sw
        load_distance   : in STD_LOGIC; --control command from cu
        distance_sw     : in STD_LOGIC_VECTOR (7 downto 0);
        
        price_out       : out STD_LOGIC_VECTOR (15 downto 0)
    );
  
end distance_and_price_unit;

architecture Behavioral of distance_and_price_unit is

    signal internal_price : unsigned (15 downto 0) := (others => '0');
    
begin

    process (clk)
    
        variable first_4_digits : integer range 0 to 9;
        variable last_4_digits  : integer range 0 to 9;
        variable total_distance : integer range 0 to 127;
        
    begin
        --clear signal to reset the registers
        if rising_edge(clk) then
            if clear_all = '1' then
                internal_price <= (others => '0');
                
            elsif load_distance = '1' then
                --converts bcd to integer
                first_4_digits := to_integer(unsigned(distance_sw(7 downto 4)));
                last_4_digits := to_integer(unsigned(distance_sw(3 downto 0)));
                --calculate the actual distance
                total_distance := (first_4_digits * 10) + last_4_digits;
                internal_price <= to_unsigned(total_distance * 2, 16); -- because the distance is in tens of km we dont have to multiply by 0.2 only by 2
            end if;
        end if;
        
    end process;
    
    price_out <= std_logic_vector(internal_price);
    
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.banknote_inventory_package.all;

entity change_and_refund_unit is

    PORT (
        refund_en       : in STD_LOGIC; -- '0' for change '1' for refund
        price_in        : in STD_LOGIC_VECTOR (15 downto 0);
        total_inserted  : in STD_LOGIC_VECTOR (15 downto 0);
        valut_in        : in valut_array;
        
        change_value_out: out STD_LOGIC_VECTOR (15 downto 0);
        change_possible : out STD_LOGIC;
        notes_dispensed : out valut_array
    );

end change_and_refund_unit;

architecture Behavioral of change_and_refund_unit is

begin

    process (refund_en, price_in, total_inserted, valut_in)
        
        variable target         : integer;
        variable remaining      : integer;
        variable needed         : integer;
        variable to_give        : integer;
        variable valut_data     : valut_array;
        variable notes_used     : valut_array;

    begin
    
        if refund_en = '1' then
            target := to_integer(unsigned(total_inserted));
        else
            if to_integer(unsigned(total_inserted)) >= to_integer(unsigned(price_in)) then
                target := to_integer(unsigned(total_inserted)) - to_integer(unsigned(price_in));
            else 
                target := 0; -- negative change safety
            end if;
        end if;
        
        remaining := target;
        valut_data := valut_in;
        notes_used  := (others => 0);
        change_value_out <= std_logic_vector(to_unsigned(target, 16));
        change_possible <= '0';
        notes_dispensed <= (others => 0);
        
        -- greedy algorith to calculate how many banknotes of each type to give
        if target > 0 then
        
            -- 100 euro (index 7)
            needed := remaining / 100;
            if needed > valut_data(7) then
                to_give := valut_data(7);
            else
                to_give := needed;
            end if;
            remaining := remaining - (to_give * 100);
            notes_used(7) := to_give;
            
            -- 50 euro (index 6)
            needed := remaining / 50;
            if needed > valut_data(6) then
                to_give := valut_data(6);
            else
                to_give := needed;
            end if;
            remaining := remaining - (to_give * 50);
            notes_used(6) := to_give;
           
            -- 20 euro (index 5)
            needed := remaining / 20;
            if needed > valut_data(5) then
                to_give := valut_data(5);
            else
                to_give := needed;
            end if;
            remaining := remaining - (to_give * 20);
            notes_used(5) := to_give;
            
            -- 10 euro (index 4)
            needed := remaining / 10;
            if needed > valut_data(4) then
                to_give := valut_data(4);
            else
                to_give := needed;
            end if;
            remaining := remaining - (to_give * 10);
            notes_used(4) := to_give;
            
            -- 5 euro (index 3)
            needed := remaining / 5;
            if needed > valut_data(3) then
                to_give := valut_data(3);
            else
                to_give := needed;
            end if;
            remaining := remaining - (to_give * 5);
            notes_used(3) := to_give;
            
            -- 2 euro (index 2)
            needed := remaining / 2;
            if needed > valut_data(2) then
                to_give := valut_data(2);
            else
                to_give := needed;
            end if;
            remaining := remaining - (to_give * 2);
            notes_used(2) := to_give;
            
            -- 1 euro (index 1)
            needed := remaining / 1;
            if needed > valut_data(1) then
                to_give := valut_data (1);
            else
                to_give := needed;
            end if;
            remaining := remaining - (to_give * 1);
            notes_used(1) := to_give;
            
            --check if change is possible
            if remaining = 0 then
                change_possible <= '1';
                notes_dispensed <= notes_used;
            else
                change_possible <= '0';
                notes_dispensed <= (others => 0);
            end if;
     
        elsif target = 0 then
            change_possible <= '1';
            notes_dispensed <= (others => 0);
        end if;          
        
    end process;
                  
end Behavioral;
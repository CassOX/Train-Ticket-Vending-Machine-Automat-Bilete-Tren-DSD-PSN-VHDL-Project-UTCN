library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.banknote_inventory_package.all; -- using the package created

entity payment_and_limit_unit is

    PORT (
        clk             : in STD_LOGIC;
        reset_sw        : in STD_LOGIC;
        clear_all       : in STD_LOGIC;
        add_money       : in STD_LOGIC;
        banknote_sw     : in STD_LOGIC_VECTOR (2 downto 0);
        price_in        : in STD_LOGIC_VECTOR (15 downto 0);
        dispense_trigger: in STD_LOGIC; -- trigger from cu so that the change can be given calculated in the change unit
        notes_dispensed : in valut_array;
        
        remaining_val   : out STD_LOGIC_VECTOR (15 downto 0);
        total_inserted  : out STD_LOGIC_VECTOR (15 downto 0);
        is_enough       : out STD_LOGIC;
        banknote_limit  : out STD_LOGIC; -- 15 banknotes per transaction
        valut_full      : out STD_LOGIC;  -- any banknote in the inventory count exceeds 100
        valut_out       : out valut_array -- data to go to change and refund unit
    );

end payment_and_limit_unit;

architecture Behavioral of payment_and_limit_unit is

    signal inserted_sum     : unsigned (15 downto 0) := (others => '0');
    --  valut inventory (permanent)
    signal valut_inventory  : valut_array            := (others => 10); -- initiallize with 10 banknotes of each type
    -- current transaction inventory
    type transaction_array is array (1 to 7) of integer range 0 to 15;
    signal transaction_count: transaction_array      := (others => 0); -- initiallize to 0;

begin
    
    process (clk)
    
        variable current_val    : integer := 0;
        variable banknote_index : integer := 0;
        
    begin
    
        if rising_edge(clk) then
            if reset_sw = '0' then
                valut_inventory     <= (others => 10);
                inserted_sum        <= (others => '0');
                transaction_count   <= (others => 0);
              
            elsif clear_all = '1' then
                inserted_sum        <= (others => '0');
                transaction_count   <= (others => 0);
                
            elsif add_money = '1' then
                --decode switches
                case banknote_sw is
                    when "001"  => current_val := 1; banknote_index := 1;
                    when "010"  => current_val := 2; banknote_index := 2;
                    when "011"  => current_val := 5; banknote_index := 3;
                    when "100"  => current_val := 10; banknote_index := 4;
                    when "101"  => current_val := 20; banknote_index := 5;
                    when "110"  => current_val := 50; banknote_index := 6;
                    when "111"  => current_val := 100; banknote_index := 7;
                    when others => current_val := 0; banknote_index := 0;
                end case;
                --check banknote limit 15 and add money to the total
                if banknote_index /= 0 then
                    if (transaction_count(banknote_index) < 15) and (valut_inventory(banknote_index) < 100) then
                        transaction_count(banknote_index)   <= transaction_count(banknote_index) + 1;
                        inserted_sum                        <= inserted_sum + to_unsigned(current_val, 16);
                        valut_inventory(banknote_index)     <= valut_inventory(banknote_index) + 1;
                    end if;
                end if;
            elsif dispense_trigger = '1' then
                --subtract what banknotes we needs to use to give the change (calculated in the change unit)
                for i in 1 to 7 loop
                    valut_inventory(i) <= valut_inventory(i) - notes_dispensed(i);
                end loop;
            end if;
        end if;
    end process;
                
    banknote_limit <= '1' when (
        (transaction_count (1) >= 15) or
        (transaction_count (2) >= 15) or
        (transaction_count (3) >= 15) or
        (transaction_count (4) >= 15) or
        (transaction_count (5) >= 15) or
        (transaction_count (6) >= 15) or
        (transaction_count (7) >= 15)) 
        else '0';
    
    valut_full <= '1' when (
        (valut_inventory (1) >= 100) or
        (valut_inventory (2) >= 100) or
        (valut_inventory (3) >= 100) or
        (valut_inventory (4) >= 100) or
        (valut_inventory (5) >= 100) or
        (valut_inventory (6) >= 100) or
        (valut_inventory (7) >= 100))
        else '0';

    total_inserted  <= std_logic_vector(inserted_sum);
    
    valut_out       <= valut_inventory; -- share valut data with the change unit
    
    is_enough <= '1' when
        inserted_sum >= unsigned(price_in)
        else '0';
       
    remaining_val <= std_logic_vector(unsigned(price_in) - inserted_sum) when
        unsigned(price_in) > inserted_sum
        else (others => '0');
        
end Behavioral;

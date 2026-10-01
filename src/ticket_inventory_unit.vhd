library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ticket_inventory_unit is

    PORT (
        clk                 : in STD_LOGIC;
        reset_sw            : in STD_LOGIC;
        decrement_tickets   : in STD_LOGIC;
        
        tickets_out         : out STD_LOGIC_VECTOR (3 downto 0);
        no_tickets          : out STD_LOGIC
    );
    
end ticket_inventory_unit;

architecture Behavioral of ticket_inventory_unit is

    signal ticket_count : unsigned(3 downto 0) := to_unsigned(10, 4); --initiallize at 10 tickets
   
begin
    
    process (clk)
    begin
    
        if rising_edge(clk) then
            if reset_sw = '0' then
                ticket_count <= to_unsigned(10, 4); -- restore default
            elsif decrement_tickets = '1' then
                if ticket_count > 0 then
                    ticket_count <= ticket_count - 1;
                end if;
            end if;
        end if;
    end process;
    
    tickets_out <= std_logic_vector(ticket_count);
    --checks for no tickets
    no_tickets <= '1' when
        ticket_count = 0
        else '0';
        
end Behavioral;
        
        
        
        
        
        
        
        
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is

    PORT ( 
        --global ports
        clk                 : in STD_LOGIC;
        reset_sw            : in STD_LOGIC;
        --user buttons
        next_btn            : in STD_LOGIC;
        insert_btn          : in STD_LOGIC;
        cancel_btn          : in STD_LOGIC;
        validate_btn        : in STD_LOGIC; --button to validate all input for the verify state so it fixes the garbage values instantly taken
        --status flags from the eu
        is_enough           : in STD_LOGIC;
        banknote_limit      : in STD_LOGIC;
        valut_full          : in STD_LOGIC;
        no_tickets          : in STD_LOGIC;
        change_possible     : in STD_LOGIC;
        --control commands to the eu
        clear_all           : out STD_LOGIC;
        load_distance       : out STD_LOGIC;
        add_money           : out STD_LOGIC;
        dispense_trigger    : out STD_LOGIC;
        decrement_tickets   : out STD_LOGIC;
        refund_en           : out STD_LOGIC;      
        --outputs
        red_led             : out STD_LOGIC;
        blue_led            : out STD_LOGIC;
        green_led           : out STD_LOGIC;
        dispense_ticket_led : out STD_LOGIC;
        dispense_money_led  : out STD_LOGIC;
        display_state       : out STD_LOGIC_VECTOR (2 downto 0) -- we can use a multiplexer to choose the state in which the 7seg display will be
    );
end control_unit;

architecture Behavioral of control_unit is

    type state_type is (IDLE, CHOOSE_DISTANCE, SHOW_PRICE, ACCEPT_MONEY, VERIFY, SUCCESS, FAIL_1, FAIL_2, REFUND);
    signal current_state, next_state : state_type;
    
begin
    --reset logic
    process (clk)
    begin
    
        if rising_edge(clk) then
            if reset_sw = '0' then
                current_state <= IDLE;
            else
                current_state <= next_state;
            end if;
        end if;
    
    end process;

    process (current_state, next_btn, insert_btn, cancel_btn, is_enough, banknote_limit, valut_full, no_tickets, change_possible)
    begin
    
        clear_all           <= '0';
        load_distance       <= '0';
        add_money           <= '0';
        dispense_trigger    <= '0';
        decrement_tickets   <= '0';
        refund_en           <= '0';
    
        red_led             <= '0';
        blue_led            <= '0';
        green_led           <= '0';
        dispense_ticket_led <= '0';
        dispense_money_led  <= '0';
        display_state       <= "100";
    
        next_state <= current_state;
        
        --global cancel feature
        if cancel_btn = '1' and ((current_state = CHOOSE_DISTANCE) or (current_state = SHOW_PRICE) or (current_state = ACCEPT_MONEY)or (current_state = VERIFY)) then
            next_state <= REFUND;
        else
            case current_state is
                --transition from idle too choosing the distance
                when IDLE =>
                    clear_all <= '1';
                    if next_btn = '1' then
                        next_state <= CHOOSE_DISTANCE;  
                    end if;
                 --transition from distance to showing the ticket price
                when CHOOSE_DISTANCE =>
                    display_state <= "000"; -- tells the display to show the distance
                    if next_btn = '1' then
                        load_distance <= '1';
                        next_state <= SHOW_PRICE;
                    end if;
                --transition from showing the price to the transaction process
                when SHOW_PRICE =>
                    display_state <= "001"; --tells the displays to show the ticket price
                    if next_btn = '1' then
                        next_state <= ACCEPT_MONEY;
                    end if;             
                --transition from the transaction process to the verification process
                when ACCEPT_MONEY =>
                    display_state <= "010"; --tells the display to show the remaning payment amount
                    if insert_btn = '1' then
                        add_money <= '1';
                    end if; 
                    if (next_btn = '1') or (is_enough = '1') then
                        next_state <= VERIFY;
                    end if;
                --checking for failure or success
                when VERIFY =>
                    display_state <= "010";
                    if validate_btn = '1' then
                        if (is_enough = '0') or (no_tickets = '1') then
                            next_state <= FAIL_1;
                        elsif change_possible = '0' then
                            next_state <= FAIL_2;
                        else
                            next_state <= SUCCESS;
                        end if;
                    end if;
                --dispensing change and tickets if success
                when SUCCESS =>
                    display_state <= "011"; -- tells the display to show the change
                    green_led <= '1';
                    dispense_ticket_led <= '1';
                    dispense_money_led <= '1';
                    if next_btn = '1' then
                        decrement_tickets <= '1';
                        dispense_trigger <= '1';
                        next_state <= IDLE;
                    end if;
                --giving refund if fail
                when FAIL_1 =>
                    red_led <= '1';
                    if next_btn = '1' then
                        next_state <= REFUND;
                    end if;
                    
                when FAIL_2 =>
                    blue_led <= '1';
                    if next_btn = '1' then
                        next_state <= REFUND;
                    end if;
                --refunding the inserted money
                when REFUND =>
                    dispense_money_led <= '1';
                    refund_en <= '1';
                    --display state is default 100 now
                    if next_btn = '1' then
                        dispense_trigger <= '1';
                        next_state <= IDLE;
                    end if;
                 
                when others =>
                    next_state <= IDLE;     
              
            end case;          
        end if;
        
    end process;
    
end Behavioral;








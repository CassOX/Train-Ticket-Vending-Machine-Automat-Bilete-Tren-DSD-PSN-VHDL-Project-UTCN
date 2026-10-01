library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level_interface is

    PORT (
        --global inputs
        clk                 : in STD_LOGIC;
        reset_sw            : in STD_LOGIC;
        --user buttons       
        next_btn            : in STD_LOGIC;
        insert_btn          : in STD_LOGIC;
        cancel_btn          : in STD_LOGIC;
        validate_btn        : in STD_LOGIC;
        --user switches
        distance_sw         : in STD_LOGIC_VECTOR (7 downto 0);
        banknote_sw         : in STD_LOGIC_VECTOR (2 downto 0);
        --leds
        red_led             : out STD_LOGIC;
        blue_led            : out STD_LOGIC;
        green_led           : out STD_LOGIC;
        dispense_ticket_led : out STD_LOGIC;
        dispense_money_led  : out STD_LOGIC;
        --7segment anode and catode
        an                  : out STD_LOGIC_VECTOR (7 downto 0);
        cat                 : out STD_LOGIC_VECTOR (6 downto 0)
    );

end top_level_interface;

architecture Structural of top_level_interface is

    --debounced buttons
    signal db_next_btn          : STD_LOGIC;
    signal db_insert_btn        : STD_LOGIC;
    signal db_cancel_btn        : STD_LOGIC;
    signal db_validate_btn      : STD_LOGIC;
    --internal signals
    signal clear_all            : STD_LOGIC;
    signal load_distance        : STD_LOGIC;
    signal add_money            : STD_LOGIC;
    signal dispense_trigger     : STD_LOGIC;
    signal decrement_tickets    : STD_LOGIC;
    signal refund_en            : STD_LOGIC;
    
    signal is_enough            : STD_LOGIC;
    signal banknote_limit       : STD_LOGIC;
    signal valut_full           : STD_LOGIC;
    signal no_tickets           : STD_LOGIC;
    signal change_possible      : STD_LOGIC;
    
    signal price_out            : STD_LOGIC_VECTOR (15 downto 0);
    signal remaining_val        : STD_LOGIC_VECTOR (15 downto 0);
    signal total_inserted       : STD_LOGIC_VECTOR (15 downto 0);
    signal change_value_out     : STD_LOGIC_VECTOR (15 downto 0);
    signal tickets_out          : STD_LOGIC_VECTOR (3 downto 0);
    
    signal ext_price            : STD_LOGIC_VECTOR (15 downto 0);
    signal ext_remaining        : STD_LOGIC_VECTOR (15 downto 0);
    signal ext_change           : STD_LOGIC_VECTOR (15 downto 0);
    
    signal bcd_price            : STD_LOGIC_VECTOR (15 downto 0);
    signal bcd_remaining        : STD_LOGIC_VECTOR (15 downto 0);
    signal bcd_change           : STD_LOGIC_VECTOR (15 downto 0);
    
    signal display_state        : STD_LOGIC_VECTOR (2 downto 0);
    signal s7d_data             : STD_LOGIC_VECTOR (15 downto 0);
    
    --debouncer component
    component MPG is
        Port ( btn : in STD_LOGIC;
               clk : in STD_LOGIC;
               en  : out STD_LOGIC);
    end component MPG;
    --execution unit component
    component execution_unit is
        PORT (
            --global inputs
            clk                 : in STD_LOGIC;
            reset_sw            : in STD_LOGIC;
            --control commands from the cu
            clear_all           : in STD_LOGIC;
            load_distance       : in STD_LOGIC;
            add_money           : in STD_LOGIC;
            dispense_trigger    : in STD_LOGIC;
            decrement_tickets   : in STD_LOGIC;
            refund_en           : in STD_LOGIC;
            --switch input
            distance_sw         : in STD_LOGIC_VECTOR (7 downto 0);
            banknote_sw         : in STD_LOGIC_VECTOR (2 downto 0);
            --status flags to the cu
            is_enough           : out STD_LOGIC;
            banknote_limit      : out STD_LOGIC;
            valut_full          : out STD_LOGIC;
            no_tickets          : out STD_LOGIC;
            change_possible     : out STD_LOGIC;
            --outputs
            price_out           : out STD_LOGIC_VECTOR (15 downto 0);
            remaining_val       : out STD_LOGIC_VECTOR (15 downto 0);
            total_inserted      : out STD_LOGIC_VECTOR (15 downto 0);
            change_value_out    : out STD_LOGIC_VECTOR (15 downto 0);
            tickets_out         : out STD_LOGIC_VECTOR (3 downto 0)
        );       
    end component execution_unit;
    --control unit component
    component control_unit is
        PORT ( 
            --global ports
            clk                 : in STD_LOGIC;
            reset_sw            : in STD_LOGIC;
            --user buttons
            next_btn            : in STD_LOGIC;
            insert_btn          : in STD_LOGIC;
            cancel_btn          : in STD_LOGIC;
            validate_btn        : in STD_LOGIC;
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
    end component control_unit;
    --binary to bcd converter component for the display
    component bcd_converter is
        PORT (
            binary_in   : in STD_LOGIC_VECTOR (15 downto 0);
            bcd_out     : out STD_LOGIC_VECTOR (15 downto 0)
        );    
    end component bcd_converter;
    --the 7 segment controler component
    component Hex_to_7seg is           
        PORT ( 
            clk     : in STD_LOGIC; -- we have to implement a frequency devider for the display refresh
            data_in : in STD_LOGIC_VECTOR (15 downto 0);              
            cat     : out STD_LOGIC_VECTOR (6 downto 0);           
            an      : out STD_LOGIC_VECTOR (7 downto 0)            
        );                                                                                                             
    end component Hex_to_7seg; 
    
begin

    --debouncers for the buttons
    debouncer_next: MPG port map (
        clk => clk,
        btn => next_btn,
        en  => db_next_btn
    );
    
    debouncer_insert: MPG port map (
        clk => clk,
        btn => insert_btn,
        en  => db_insert_btn
    );
    
    debouncer_cancel: MPG port map (
        clk => clk,
        btn => cancel_btn,
        en  => db_cancel_btn
    );
    
    debouncer_validate: MPG port map (
        clk => clk,
        btn => validate_btn,
        en  => db_validate_btn
    );
    
    eu: execution_unit port map (
        clk                 => clk, 
        reset_sw            => reset_sw,
        clear_all           => clear_all, 
        load_distance       => load_distance, 
        add_money           => add_money,
        dispense_trigger    => dispense_trigger, 
        decrement_tickets   => decrement_tickets, 
        refund_en           => refund_en,
        distance_sw         => distance_sw, 
        banknote_sw         => banknote_sw,
        is_enough           => is_enough, 
        banknote_limit      => banknote_limit, 
        valut_full          => valut_full,
        no_tickets          => no_tickets, 
        change_possible     => change_possible,
        price_out           => price_out, 
        remaining_val       => remaining_val,
        total_inserted      => total_inserted, 
        change_value_out    => change_value_out, 
        tickets_out         => tickets_out    
    );
    
    cu: control_unit port map (
        clk                 => clk, 
        reset_sw            => reset_sw,
        next_btn            => db_next_btn, 
        insert_btn          => db_insert_btn, 
        cancel_btn          => db_cancel_btn, 
        validate_btn        => db_validate_btn,       
        is_enough           => is_enough, 
        banknote_limit      => banknote_limit, 
        valut_full          => valut_full,
        no_tickets          => no_tickets, 
        change_possible     => change_possible,
        clear_all           => clear_all, 
        load_distance       => load_distance, 
        add_money           => add_money,
        dispense_trigger    => dispense_trigger, 
        decrement_tickets   => decrement_tickets, 
        refund_en           => refund_en,
        red_led             => red_led, 
        blue_led            => blue_led, 
        green_led           => green_led,
        dispense_ticket_led => dispense_ticket_led, 
        dispense_money_led  => dispense_money_led,
        display_state       => display_state
    );
    
    ext_price       <= price_out;
    ext_remaining   <= remaining_val;
    ext_change      <= change_value_out;
    
    display_price: bcd_converter port map (
        binary_in   => ext_price,
        bcd_out     => bcd_price
    );
    
    display_remaning: bcd_converter port map (
        binary_in   => ext_remaining,
        bcd_out     => bcd_remaining
    );
    
    display_change: bcd_converter port map (
        binary_in   => ext_change,
        bcd_out     => bcd_change
    );
    
    display: Hex_to_7seg port map(
        clk     => clk,
        data_in => s7d_data,
        cat     => cat,
        an      => an
    );
    
    --7 segment display multiplexer logic
    process (display_state, distance_sw, price_out, remaining_val, change_value_out)
    begin
        
        case display_state is
            when "000"  => s7d_data <= "0000" & distance_sw & "0000";
            when "001"  => s7d_data <= bcd_price;
            when "010"  => s7d_data <= bcd_remaining;
            when "011"  => s7d_data <= bcd_change;
            when others => s7d_data <= (others => '0');
        end case;
        
    end process;
    
end Structural;

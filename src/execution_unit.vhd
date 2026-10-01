library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.banknote_inventory_package.all;

entity execution_unit is

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
    
end execution_unit;

architecture Structural of execution_unit is
    --component declarations
    component distance_and_price_unit is
        PORT (
            clk             : in STD_LOGIC;
            clear_all       : in STD_LOGIC; --triggers by cancel_btn or reset_sw
            load_distance   : in STD_LOGIC; --control command from cu
            distance_sw     : in STD_LOGIC_VECTOR (7 downto 0);
            
            price_out       : out STD_LOGIC_VECTOR (15 downto 0)
        ); 
    end component distance_and_price_unit;
    
    component payment_and_limit_unit is
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
    end component payment_and_limit_unit;

    component ticket_inventory_unit is
        PORT (
            clk                 : in STD_LOGIC;
            reset_sw            : in STD_LOGIC;
            decrement_tickets   : in STD_LOGIC;
            tickets_out         : out STD_LOGIC_VECTOR (3 downto 0);
            no_tickets          : out STD_LOGIC
        );       
    end component ticket_inventory_unit;
    
    component change_and_refund_unit is
        PORT (
            refund_en       : in STD_LOGIC; -- '0' for change '1' for refund
            price_in        : in STD_LOGIC_VECTOR (15 downto 0);
            total_inserted  : in STD_LOGIC_VECTOR (15 downto 0);
            valut_in        : in valut_array;
            
            change_value_out: out STD_LOGIC_VECTOR (15 downto 0);
            change_possible : out STD_LOGIC;
            notes_dispensed : out valut_array
        );   
    end component change_and_refund_unit;
    
    --internal signals to communicate between unit
    signal sig_price            : STD_LOGIC_VECTOR (15 downto 0);
    signal sig_total_inserted   : STD_LOGIC_VECTOR (15 downto 0);
    signal sig_valut_data       : valut_array;
    signal sig_notes_dispensed  : valut_array;
    
begin

    u1_distance: distance_and_price_unit port map (
        clk             => clk,
        clear_all       => clear_all,
        load_distance   => load_distance,
        distance_sw     => distance_sw,
        price_out       => sig_price
    );
    
    u2_payment: payment_and_limit_unit port map (
        clk                 => clk,
        reset_sw            => reset_sw,
        clear_all           => clear_all,
        add_money           => add_money,
        banknote_sw         => banknote_sw,
        price_in            => sig_price,
        dispense_trigger    => dispense_trigger,
        notes_dispensed     => sig_notes_dispensed,
        remaining_val       => remaining_val,
        total_inserted      => sig_total_inserted,
        is_enough           => is_enough,
        banknote_limit      => banknote_limit,
        valut_full          => valut_full,
        valut_out           => sig_valut_data
    );
    
    u3_tickets: ticket_inventory_unit port map (
        clk                 => clk,
        reset_sw            => reset_sw,
        decrement_tickets   => decrement_tickets,
        tickets_out         => tickets_out,
        no_tickets          => no_tickets
    );
        
    u4_change: change_and_refund_unit port map (
        refund_en           => refund_en,
        price_in            => sig_price,
        total_inserted      => sig_total_inserted,
        valut_in            => sig_valut_data,
        change_value_out    => change_value_out,
        change_possible     => change_possible,
        notes_dispensed     => sig_notes_dispensed
    );
        
    price_out       <= sig_price;
    total_inserted  <= sig_total_inserted;
    
end Structural;
        
        
        
        
        

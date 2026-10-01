----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2024 12:52:44 PM
-- Design Name: 
-- Module Name: Hex_to_7seg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Hex_to_7seg is           -- cele 7 segmente in sensul invers accelor de ceasorinic se numesc a,b,c,d,e,f si sunt in logica negativa
    PORT ( 
        clk     : in STD_LOGIC; -- we have to implement a frequency devider for the display refresh
        data_in : in STD_LOGIC_VECTOR (15 downto 0);              
        cat     : out STD_LOGIC_VECTOR (6 downto 0);           
        an      : out STD_LOGIC_VECTOR (7 downto 0)            --      a
    );                                                         --      __
                                                             --     f|   |b
end Hex_to_7seg;                                             --       ---
                                                             --     e| g |c
architecture Behavioral of Hex_to_7seg is                    --       ---  
                                                              --       d
    signal refresh_counter          : STD_LOGIC_VECTOR (19 downto 0) := (others => '0');
    signal led_activating_counter   : STD_LOGIC_VECTOR (1 downto 0);
    signal led_bcd                  : STD_LOGIC_VECTOR (3 downto 0);
                                                              
begin

    --refresh the desplay
    process (clk)
    begin
    
        if rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    
    end process;

    led_activating_counter <= refresh_counter(19 downto 18);
    
    process (led_activating_counter, data_in)
    begin
        --anode activation
        case led_activating_counter is
            when "00" =>
                an <= "11111110"; -- actifate digit 0
                led_bcd <= data_in(3 downto 0);
            when "01" =>
                an <= "11111101"; -- activate digit 1
                led_bcd <= data_in(7 downto 4);
            when "10" =>
                an <= "11111011"; -- activate digit 2
                led_bcd <= data_in(11 downto 8);
            when "11" =>
                an <= "11110111"; -- activate digit 3
                led_bcd <= data_in(15 downto 12);
            when others =>
                an <= "11111111"; -- turn all off
                led_bcd <= "0000";
        end case;
            
    end process; 
    
    --decode the cathodes
    process(led_bcd)
    begin
    
        case led_bcd is
            when "0000" => cat <= "1000000"; --0
            when "0001" => cat <= "1111001"; --1
            when "0010" => cat <= "0100100"; --2
            when "0011" => cat <= "0110000"; --3
            when "0100" => cat <= "0011001"; --4
            when "0101" => cat <= "0010010"; --5
            when "0110" => cat <= "0000010"; --6
            when "0111" => cat <= "1111000"; --7
            when "1000" => cat <= "0000000"; --8
            when "1001" => cat <= "0010000"; --9
            when others => cat <= "1111111"; --turn off
        end case;
        
    end process;    

end Behavioral;

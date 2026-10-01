library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- i made a package to so i can use the banknote inventory for both the payment unit and the change unit (its shared)

package banknote_inventory_package is

    type valut_array is array (1 to 7) of integer range 0 to 127;
    
end package banknote_inventory_package;
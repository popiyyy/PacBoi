library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Color converter for Digilent Basys 3 12-bit VGA (4 bits per channel)
ENTITY YAKUZA_CONV IS
    PORT(
        color_bit   : IN  std_logic;
        video_on    : IN  std_logic;
        red_fourbit : OUT std_logic_vector(3 DOWNTO 0);
        blue_fourbit: OUT std_logic_vector(3 DOWNTO 0);
        green_fourbit:OUT std_logic_vector(3 DOWNTO 0)
    );
END ENTITY YAKUZA_CONV;

ARCHITECTURE four_bit OF YAKUZA_CONV IS
BEGIN
    process(color_bit, video_on)
    begin
        if video_on = '1' then
            if color_bit = '1' then
                red_fourbit   <= "1111"; -- Yellow (Pacman color)
                green_fourbit <= "1111";
                blue_fourbit  <= "0000";
            else 
                red_fourbit   <= "0000"; -- Black background
                green_fourbit <= "0000";
                blue_fourbit  <= "0000";
            end if;
        else
            -- Blanking region (outside active 640x480 area)
            red_fourbit   <= "0000";
            green_fourbit <= "0000";
            blue_fourbit  <= "0000";
        end if;
    end process;
END ARCHITECTURE four_bit;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Clock divider for Digilent Basys 3
-- Input: 100 MHz oscillator (pin W5)
-- Outputs: 25 MHz VGA pixel clock and ~5 Hz Game clock
ENTITY clkdiv IS
    PORT(
        clk        : IN  std_logic; -- 100 MHz oscillator
        reset      : IN  std_logic := '0';
        clk_25mhz  : OUT std_logic; -- 25 MHz pixel clock
        clk_game   : OUT std_logic  -- ~5 Hz game tick clock
    ); 
END clkdiv;

ARCHITECTURE behavior OF clkdiv IS
    SIGNAL count_25m  : unsigned(1 downto 0) := (others => '0');
    SIGNAL count_game : unsigned(24 downto 0) := (others => '0');
    SIGNAL reg_25m    : std_logic := '0';
    SIGNAL reg_game   : std_logic := '0';
BEGIN

    -- Frequency divider: 100 MHz / 4 = 25 MHz
    process(clk, reset)
    begin
        if reset = '1' then
            count_25m <= (others => '0');
            reg_25m   <= '0';
        elsif rising_edge(clk) then
            if count_25m = 1 then
                reg_25m <= not reg_25m;
                count_25m <= count_25m + 1;
            elsif count_25m = 3 then
                reg_25m <= not reg_25m;
                count_25m <= (others => '0');
            else
                count_25m <= count_25m + 1;
            end if;
        end if;
    end process;
    clk_25mhz <= reg_25m;

    -- Frequency divider: 100 MHz / 20,000,000 = 5 Hz (toggle every 10,000,000 cycles)
    process(clk, reset)
    begin
        if reset = '1' then
            count_game <= (others => '0');
            reg_game   <= '0';
        elsif rising_edge(clk) then
            if count_game >= 9999999 then
                count_game <= (others => '0');
                reg_game <= not reg_game;
            else
                count_game <= count_game + 1;
            end if;
        end if;
    end process;
    clk_game <= reg_game;

END behavior;

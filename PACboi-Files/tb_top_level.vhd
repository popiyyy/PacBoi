library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Testbench for PacBoi top_level on Vivado Simulator
ENTITY tb_top_level IS
END ENTITY tb_top_level;

ARCHITECTURE sim OF tb_top_level IS

    -- Component Declaration
    COMPONENT top_level IS
        PORT(
            clk       : IN  std_logic;
            sw_reset  : IN  std_logic;
            btn_start : IN  std_logic;
            btn_up    : IN  std_logic;
            btn_down  : IN  std_logic;
            btn_left  : IN  std_logic;
            btn_right : IN  std_logic;
            hsync     : OUT std_logic;
            vsync     : OUT std_logic;
            vgaRed    : OUT std_logic_vector(3 DOWNTO 0);
            vgaGreen  : OUT std_logic_vector(3 DOWNTO 0);
            vgaBlue   : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals
    SIGNAL clk       : std_logic := '0';
    SIGNAL sw_reset  : std_logic := '1';
    SIGNAL btn_start : std_logic := '0';
    SIGNAL btn_up    : std_logic := '0';
    SIGNAL btn_down  : std_logic := '0';
    SIGNAL btn_left  : std_logic := '0';
    SIGNAL btn_right : std_logic := '0';

    SIGNAL hsync     : std_logic;
    SIGNAL vsync     : std_logic;
    SIGNAL vgaRed    : std_logic_vector(3 DOWNTO 0);
    SIGNAL vgaGreen  : std_logic_vector(3 DOWNTO 0);
    SIGNAL vgaBlue   : std_logic_vector(3 DOWNTO 0);

    CONSTANT clk_period : time := 10 ns; -- 100 MHz clock period

BEGIN

    -- Instantiate Unit Under Test (UUT)
    uut: top_level
        PORT MAP(
            clk       => clk,
            sw_reset  => sw_reset,
            btn_start => btn_start,
            btn_up    => btn_up,
            btn_down  => btn_down,
            btn_left  => btn_left,
            btn_right => btn_right,
            hsync     => hsync,
            vsync     => vsync,
            vgaRed    => vgaRed,
            vgaGreen  => vgaGreen,
            vgaBlue   => vgaBlue
        );

    -- Clock Generation: 100 MHz oscillator
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        -- 1. Hold reset for 100 ns
        sw_reset <= '1';
        wait for 100 ns;
        sw_reset <= '0';
        wait for 200 ns;

        -- 2. Simulate start button press
        btn_start <= '1';
        wait for 100 ns;
        btn_start <= '0';
        wait for 500 ns;

        -- 3. Simulate direction button (move right)
        btn_right <= '1';
        wait for 200 ns;
        btn_right <= '0';

        -- Let simulation run to observe VGA horizontal sync and pixel output
        wait for 100 us;

        -- End simulation
        wait;
    end process;

END ARCHITECTURE sim;

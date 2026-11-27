library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Top-Level VHDL Module for PacBoi on Digilent Basys 3 FPGA
-- Replaces Quartus II Block Diagram (vgaA.bdf)
ENTITY top_level IS
    PORT(
        clk       : IN  std_logic; -- 100 MHz oscillator (pin W5)
        sw_reset  : IN  std_logic; -- Slide switch 0 (pin V17)
        btn_start : IN  std_logic; -- Push button Center (pin U18)
        btn_up    : IN  std_logic; -- Push button Up (pin T18)
        btn_down  : IN  std_logic; -- Push button Down (pin U17)
        btn_left  : IN  std_logic; -- Push button Left (pin W19)
        btn_right : IN  std_logic; -- Push button Right (pin T17)
        hsync     : OUT std_logic; -- VGA Horizontal Sync (pin P19)
        vsync     : OUT std_logic; -- VGA Vertical Sync (pin R19)
        vgaRed    : OUT std_logic_vector(3 DOWNTO 0); -- VGA Red (G19, H19, J19, N19)
        vgaGreen  : OUT std_logic_vector(3 DOWNTO 0); -- VGA Green (J17, H17, G17, D17)
        vgaBlue   : OUT std_logic_vector(3 DOWNTO 0)  -- VGA Blue (N18, L18, K18, J18)
    );
END ENTITY top_level;

ARCHITECTURE structural OF top_level IS

    -- Component Declarations
    COMPONENT clkdiv IS
        PORT(
            clk        : IN  std_logic;
            reset      : IN  std_logic;
            clk_25mhz  : OUT std_logic;
            clk_game   : OUT std_logic
        );
    END COMPONENT;

    COMPONENT VGASYNC IS
        PORT(
            clock_25Mhz                    : IN  STD_LOGIC;
            red, green, blue               : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            red_out, green_out, blue_out   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            horiz_sync_out, vert_sync_out  : OUT STD_LOGIC;
            video_on                       : OUT STD_LOGIC;
            pixel_row, pixel_column        : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT Char_ROM IS
        PORT(
            clk                : IN  STD_LOGIC;
            character_address  : IN  STD_LOGIC_VECTOR(13 DOWNTO 0);
            font_row, font_col : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            rom_mux_output     : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT YAKUZA_CONV IS
        PORT(
            color_bit   : IN  std_logic;
            video_on    : IN  std_logic;
            red_fourbit : OUT std_logic_vector(3 DOWNTO 0);
            blue_fourbit: OUT std_logic_vector(3 DOWNTO 0);
            green_fourbit:OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT pause_menu IS
        PORT(
            pixel_row      : IN  std_logic_vector(9 DOWNTO 0);
            pixel_col      : IN  std_logic_vector(9 DOWNTO 0);
            pause_sel      : IN  std_logic;
            game_over      : IN  std_logic := '0';
            score_val      : IN  integer range 0 to 99 := 0;
            high_score_val : IN  integer range 0 to 99 := 0;
            box_active     : OUT std_logic;
            pixel_on       : OUT std_logic;
            hud_pixel_on   : OUT std_logic
        );
    END COMPONENT;

    COMPONENT msgHello IS
        PORT(
            Pixel_row: IN std_logic_vector(9 downto 0);
            Pixel_col: IN std_logic_vector(9 downto 0);
            enableMsg : IN std_logic;
            pimpclock, clk : IN STD_LOGIC;
            S_SWITCH, R_SWITCH, B_UP, B_DOWN, B_LEFT, B_RIGHT : IN std_logic;
            pause_en       : IN std_logic := '0';
            score_out      : OUT integer range 0 to 99;
            high_score_out : OUT integer range 0 to 99;
            game_over_out  : OUT std_logic;
            Char_address   : OUT std_logic_vector(13 downto 0);
            Char_address2: buffer std_logic_vector(7 downto 0);
            Font_row     : OUT std_logic_vector(3 downto 0);
            Font_col     : OUT std_logic_vector(3 downto 0)
        );
    END COMPONENT;

    -- Internal Interconnect Signals (Table 3.4)
    SIGNAL clk_25MHz       : std_logic;
    SIGNAL clk_game        : std_logic;
    SIGNAL pixel_row_sig   : std_logic_vector(9 DOWNTO 0);
    SIGNAL pixel_col_sig   : std_logic_vector(9 DOWNTO 0);
    SIGNAL video_on_sig    : std_logic;
    SIGNAL char_addr_sig   : std_logic_vector(13 DOWNTO 0);
    SIGNAL font_row_sig    : std_logic_vector(3 DOWNTO 0);
    SIGNAL font_col_sig    : std_logic_vector(3 DOWNTO 0);
    SIGNAL color_bit_sig   : std_logic;
    SIGNAL red_conv_sig    : std_logic_vector(3 DOWNTO 0);
    SIGNAL green_conv_sig  : std_logic_vector(3 DOWNTO 0);
    SIGNAL blue_conv_sig   : std_logic_vector(3 DOWNTO 0);

    -- Start/Pause State Logic
    SIGNAL btn_start_prev  : std_logic := '0';
    SIGNAL btn_up_prev     : std_logic := '0';
    SIGNAL btn_down_prev   : std_logic := '0';
    SIGNAL game_running    : std_logic := '1';
    SIGNAL game_over_sig   : std_logic := '0';
    SIGNAL game_over_state : std_logic := '0';
    SIGNAL game_paused     : std_logic;
    SIGNAL pause_sel       : std_logic := '0'; -- '0' = LANJUTKAN, '1' = ULANG
    SIGNAL restart_cnt     : integer range 0 to 1000000 := 0;
    SIGNAL restart_pulse   : std_logic := '0';
    SIGNAL game_reset_sig  : std_logic;
    SIGNAL clk_game_gated  : std_logic;
    SIGNAL btn_up_gated    : std_logic;
    SIGNAL btn_down_gated  : std_logic;
    SIGNAL btn_left_gated  : std_logic;
    SIGNAL btn_right_gated : std_logic;
    SIGNAL pause_box_active: std_logic;
    SIGNAL pause_pixel_on  : std_logic;
    SIGNAL hud_pixel_on_sig: std_logic;
    SIGNAL score_sig       : integer range 0 to 99 := 0;
    SIGNAL high_score_sig  : integer range 0 to 99 := 0;
    SIGNAL final_color_bit : std_logic;

BEGIN

    -- Start/Pause & Menu Navigation Controller
    process(clk_25MHz, sw_reset)
    begin
        if sw_reset = '1' then
            game_running    <= '1';
            game_over_state <= '0';
            pause_sel       <= '0';
            btn_start_prev  <= '0';
            btn_up_prev     <= '0';
            btn_down_prev   <= '0';
            restart_cnt     <= 0;
            restart_pulse   <= '0';
        elsif rising_edge(clk_25MHz) then
            btn_start_prev <= btn_start;
            btn_up_prev    <= btn_up;
            btn_down_prev  <= btn_down;

            if restart_cnt > 0 then
                restart_cnt   <= restart_cnt - 1;
                restart_pulse <= '1';
            else
                restart_pulse <= '0';
            end if;

            if game_over_state = '1' then
                -- Wait for player to press Start on "> LANJUT"
                if (btn_start = '1' and btn_start_prev = '0') then
                    game_over_state <= '0';
                    game_running    <= '1';
                    restart_cnt     <= 1000000; -- ~40ms reset pulse to clear score & positions
                end if;
            elsif (game_over_sig = '1' and restart_cnt = 0) then
                -- Ghost caught Pacman -> enter Game Over screen
                game_over_state <= '1';
            elsif game_running = '1' then
                if (btn_start = '1' and btn_start_prev = '0') then
                    game_running <= '0';
                    pause_sel    <= '0';
                end if;
            else
                -- Menu navigation while paused
                if (btn_up = '1' and btn_up_prev = '0') then
                    pause_sel <= '0'; -- 1. LANJUTKAN
                elsif (btn_down = '1' and btn_down_prev = '0') then
                    pause_sel <= '1'; -- 2. ULANG
                end if;

                if (btn_start = '1' and btn_start_prev = '0') then
                    game_running <= '1';
                    if pause_sel = '1' then
                        restart_cnt <= 1000000; -- ~40ms reset pulse at 25MHz
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Freeze game clock and player movements when paused or game over
    game_paused     <= (not game_running) or game_over_state;
    game_reset_sig  <= sw_reset or restart_pulse;
    clk_game_gated  <= clk_game  when (game_running = '1' and game_over_state = '0') else '0';
    btn_up_gated    <= btn_up    when (game_running = '1' and game_over_state = '0') else '0';
    btn_down_gated  <= btn_down  when (game_running = '1' and game_over_state = '0') else '0';
    btn_left_gated  <= btn_left  when (game_running = '1' and game_over_state = '0') else '0';
    btn_right_gated <= btn_right when (game_running = '1' and game_over_state = '0') else '0';

    -- 1. Clock Divider Module (100 MHz -> 25 MHz & Game Clock)
    u_clkdiv: clkdiv
        PORT MAP(
            clk        => clk,
            reset      => sw_reset,
            clk_25mhz  => clk_25MHz,
            clk_game   => clk_game
        );

    -- 2. VGA Synchronization Controller
    u_vgasync: VGASYNC
        PORT MAP(
            clock_25Mhz    => clk_25MHz,
            red            => red_conv_sig,
            green          => green_conv_sig,
            blue           => blue_conv_sig,
            red_out        => vgaRed,
            green_out      => vgaGreen,
            blue_out       => vgaBlue,
            horiz_sync_out => hsync,
            vert_sync_out  => vsync,
            video_on       => video_on_sig,
            pixel_row      => pixel_row_sig,
            pixel_column   => pixel_col_sig
        );

    -- 3. PacBoi Main Game Logic Controller
    u_msghello: msgHello
        PORT MAP(
            Pixel_row     => pixel_row_sig,
            Pixel_col     => pixel_col_sig,
            enableMsg     => '1',
            pimpclock     => clk_game_gated,
            clk           => clk_25MHz,
            S_SWITCH      => '1', -- Pacman mode enabled
            R_SWITCH      => game_reset_sig,
            B_UP          => btn_up_gated,
            B_DOWN        => btn_down_gated,
            B_LEFT        => btn_left_gated,
            B_RIGHT       => btn_right_gated,
            pause_en       => game_paused,
            score_out      => score_sig,
            high_score_out => high_score_sig,
            game_over_out  => game_over_sig,
            Char_address   => char_addr_sig,
            Char_address2 => open,
            Font_row      => font_row_sig,
            Font_col      => font_col_sig
        );

    -- 4. Character Sprite ROM (Inferred Block RAM)
    u_char_rom: Char_ROM
        PORT MAP(
            clk               => clk_25MHz,
            character_address => char_addr_sig,
            font_row          => font_row_sig,
            font_col          => font_col_sig,
            rom_mux_output    => color_bit_sig
        );

    -- 4b. Pause Menu & Game Over Overlay
    u_pause_menu: pause_menu
        PORT MAP(
            pixel_row      => pixel_row_sig,
            pixel_col      => pixel_col_sig,
            pause_sel      => pause_sel,
            game_over      => game_over_state,
            score_val      => score_sig,
            high_score_val => high_score_sig,
            box_active     => pause_box_active,
            pixel_on       => pause_pixel_on,
            hud_pixel_on   => hud_pixel_on_sig
        );

    final_color_bit <= pause_pixel_on when ((game_running = '0' or game_over_state = '1') and pause_box_active = '1') else (color_bit_sig or hud_pixel_on_sig);

    -- 5. 12-bit RGB Color Converter
    u_yakuza_conv: YAKUZA_CONV
        PORT MAP(
            color_bit    => final_color_bit,
            video_on     => video_on_sig,
            red_fourbit  => red_conv_sig,
            blue_fourbit => blue_conv_sig,
            green_fourbit=> green_conv_sig
        );

END ARCHITECTURE structural;

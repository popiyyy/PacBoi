library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Pause Menu Overlay for PacBoi
-- Displays a centered black box with yellow text:
--       PAUSE
--   > 1.  LANJUTKAN
--     2.  ULANG
ENTITY pause_menu IS
    PORT(
        pixel_row      : IN  std_logic_vector(9 DOWNTO 0);
        pixel_col      : IN  std_logic_vector(9 DOWNTO 0);
        pause_sel      : IN  std_logic; -- '0' = LANJUTKAN, '1' = ULANG
        game_over      : IN  std_logic := '0'; -- '1' = KAMU KALAH screen
        score_val      : IN  integer range 0 to 99 := 0;
        high_score_val : IN  integer range 0 to 99 := 0;
        box_active     : OUT std_logic; -- '1' when inside the pause/game-over box
        pixel_on       : OUT std_logic; -- '1' for yellow text/cursor, '0' for black
        hud_pixel_on   : OUT std_logic  -- '1' for yellow HUD labels & scores
    );
END ENTITY pause_menu;

ARCHITECTURE behavioral OF pause_menu IS
    -- Box bounds (centered on 640x480)
    CONSTANT BOX_LEFT   : integer := 120;
    CONSTANT BOX_RIGHT  : integer := 519;
    CONSTANT BOX_TOP    : integer := 140;
    CONSTANT BOX_BOTTOM : integer := 339;

    -- Character codes (5-bit index into 8x8 font ROM)
    CONSTANT CH_SPACE : integer := 0;
    CONSTANT CH_P     : integer := 1;
    CONSTANT CH_A     : integer := 2;
    CONSTANT CH_U     : integer := 3;
    CONSTANT CH_S     : integer := 4;
    CONSTANT CH_E     : integer := 5;
    CONSTANT CH_L     : integer := 6;
    CONSTANT CH_N     : integer := 7;
    CONSTANT CH_J     : integer := 8;
    CONSTANT CH_T     : integer := 9;
    CONSTANT CH_K     : integer := 10;
    CONSTANT CH_G     : integer := 11;
    CONSTANT CH_1     : integer := 12;
    CONSTANT CH_2     : integer := 13;
    CONSTANT CH_DOT   : integer := 14;
    CONSTANT CH_ARROW : integer := 15;
    CONSTANT CH_O     : integer := 16;
    CONSTANT CH_R     : integer := 17;
    CONSTANT CH_I     : integer := 18;
    CONSTANT CH_EQ    : integer := 19;
    CONSTANT CH_0     : integer := 20;
    CONSTANT CH_3     : integer := 21;
    CONSTANT CH_4     : integer := 22;
    CONSTANT CH_5     : integer := 23;
    CONSTANT CH_6     : integer := 24;
    CONSTANT CH_7     : integer := 25;
    CONSTANT CH_8     : integer := 26;
    CONSTANT CH_9     : integer := 27;
    CONSTANT CH_M     : integer := 28;
    CONSTANT CH_H     : integer := 29;

    FUNCTION digit_to_ch(d : integer) RETURN integer IS
    BEGIN
        case d is
            when 0 => return CH_0;
            when 1 => return CH_1;
            when 2 => return CH_2;
            when 3 => return CH_3;
            when 4 => return CH_4;
            when 5 => return CH_5;
            when 6 => return CH_6;
            when 7 => return CH_7;
            when 8 => return CH_8;
            when 9 => return CH_9;
            when others => return CH_0;
        end case;
    END FUNCTION;

    -- Returns 8-bit row of an 8x8 character glyph
    FUNCTION get_glyph_row(ch : integer; row : integer) RETURN std_logic_vector IS
        variable r : std_logic_vector(7 downto 0) := (others => '0');
    BEGIN
        case ch is
            when CH_P =>
                case row is
                    when 0 => r := "01111100";
                    when 1 => r := "01100110";
                    when 2 => r := "01100110";
                    when 3 => r := "01111100";
                    when 4 => r := "01100000";
                    when 5 => r := "01100000";
                    when 6 => r := "01100000";
                    when others => r := "00000000";
                end case;
            when CH_A =>
                case row is
                    when 0 => r := "00111100";
                    when 1 => r := "01100110";
                    when 2 => r := "01100110";
                    when 3 => r := "01111110";
                    when 4 => r := "01100110";
                    when 5 => r := "01100110";
                    when 6 => r := "01100110";
                    when others => r := "00000000";
                end case;
            when CH_U =>
                case row is
                    when 0 => r := "01100110";
                    when 1 => r := "01100110";
                    when 2 => r := "01100110";
                    when 3 => r := "01100110";
                    when 4 => r := "01100110";
                    when 5 => r := "01100110";
                    when 6 => r := "00111100";
                    when others => r := "00000000";
                end case;
            when CH_S =>
                case row is
                    when 0 => r := "00111110";
                    when 1 => r := "01100000";
                    when 2 => r := "01100000";
                    when 3 => r := "00111100";
                    when 4 => r := "00000110";
                    when 5 => r := "00000110";
                    when 6 => r := "01111100";
                    when others => r := "00000000";
                end case;
            when CH_E =>
                case row is
                    when 0 => r := "01111110";
                    when 1 => r := "01100000";
                    when 2 => r := "01100000";
                    when 3 => r := "01111100";
                    when 4 => r := "01100000";
                    when 5 => r := "01100000";
                    when 6 => r := "01111110";
                    when others => r := "00000000";
                end case;
            when CH_L =>
                case row is
                    when 0 => r := "01100000";
                    when 1 => r := "01100000";
                    when 2 => r := "01100000";
                    when 3 => r := "01100000";
                    when 4 => r := "01100000";
                    when 5 => r := "01100000";
                    when 6 => r := "01111110";
                    when others => r := "00000000";
                end case;
            when CH_N =>
                case row is
                    when 0 => r := "01100110";
                    when 1 => r := "01110110";
                    when 2 => r := "01111110";
                    when 3 => r := "01101110";
                    when 4 => r := "01100110";
                    when 5 => r := "01100110";
                    when 6 => r := "01100110";
                    when others => r := "00000000";
                end case;
            when CH_J =>
                case row is
                    when 0 => r := "00011110";
                    when 1 => r := "00000110";
                    when 2 => r := "00000110";
                    when 3 => r := "00000110";
                    when 4 => r := "01100110";
                    when 5 => r := "01100110";
                    when 6 => r := "00111100";
                    when others => r := "00000000";
                end case;
            when CH_T =>
                case row is
                    when 0 => r := "01111110";
                    when 1 => r := "00011000";
                    when 2 => r := "00011000";
                    when 3 => r := "00011000";
                    when 4 => r := "00011000";
                    when 5 => r := "00011000";
                    when 6 => r := "00011000";
                    when others => r := "00000000";
                end case;
            when CH_K =>
                case row is
                    when 0 => r := "01100110";
                    when 1 => r := "01101100";
                    when 2 => r := "01111000";
                    when 3 => r := "01110000";
                    when 4 => r := "01111000";
                    when 5 => r := "01101100";
                    when 6 => r := "01100110";
                    when others => r := "00000000";
                end case;
            when CH_G =>
                case row is
                    when 0 => r := "00111100";
                    when 1 => r := "01100110";
                    when 2 => r := "01100000";
                    when 3 => r := "01101110";
                    when 4 => r := "01100110";
                    when 5 => r := "01100110";
                    when 6 => r := "00111100";
                    when others => r := "00000000";
                end case;
            when CH_1 =>
                case row is
                    when 0 => r := "00011000";
                    when 1 => r := "00111000";
                    when 2 => r := "00011000";
                    when 3 => r := "00011000";
                    when 4 => r := "00011000";
                    when 5 => r := "00011000";
                    when 6 => r := "01111110";
                    when others => r := "00000000";
                end case;
            when CH_2 =>
                case row is
                    when 0 => r := "00111100";
                    when 1 => r := "01100110";
                    when 2 => r := "00000110";
                    when 3 => r := "00011100";
                    when 4 => r := "00110000";
                    when 5 => r := "01100000";
                    when 6 => r := "01111110";
                    when others => r := "00000000";
                end case;
            when CH_DOT =>
                case row is
                    when 5 => r := "01100000";
                    when 6 => r := "01100000";
                    when others => r := "00000000";
                end case;
            when CH_ARROW =>
                case row is
                    when 1 => r := "01000000";
                    when 2 => r := "01110000";
                    when 3 => r := "01111100";
                    when 4 => r := "01110000";
                    when 5 => r := "01000000";
                    when others => r := "00000000";
                end case;
            when CH_O =>
                case row is
                    when 0 => r := "00111100";
                    when 1 => r := "01100110";
                    when 2 => r := "01100110";
                    when 3 => r := "01100110";
                    when 4 => r := "01100110";
                    when 5 => r := "01100110";
                    when 6 => r := "00111100";
                    when others => r := "00000000";
                end case;
            when CH_R =>
                case row is
                    when 0 => r := "01111100";
                    when 1 => r := "01100110";
                    when 2 => r := "01100110";
                    when 3 => r := "01111100";
                    when 4 => r := "01111000";
                    when 5 => r := "01101100";
                    when 6 => r := "01100110";
                    when others => r := "00000000";
                end case;
            when CH_I =>
                case row is
                    when 0 => r := "01111110";
                    when 1 => r := "00011000";
                    when 2 => r := "00011000";
                    when 3 => r := "00011000";
                    when 4 => r := "00011000";
                    when 5 => r := "00011000";
                    when 6 => r := "01111110";
                    when others => r := "00000000";
                end case;
            when CH_EQ =>
                case row is
                    when 2 => r := "01111110";
                    when 4 => r := "01111110";
                    when others => r := "00000000";
                end case;
            when CH_0 =>
                case row is
                    when 0 => r := "00111100";
                    when 1 => r := "01100110";
                    when 2 => r := "01101110";
                    when 3 => r := "01110110";
                    when 4 => r := "01100110";
                    when 5 => r := "01100110";
                    when 6 => r := "00111100";
                    when others => r := "00000000";
                end case;
            when CH_3 =>
                case row is
                    when 0 => r := "00111100";
                    when 1 => r := "01100110";
                    when 2 => r := "00000110";
                    when 3 => r := "00011100";
                    when 4 => r := "00000110";
                    when 5 => r := "01100110";
                    when 6 => r := "00111100";
                    when others => r := "00000000";
                end case;
            when CH_4 =>
                case row is
                    when 0 => r := "00001100";
                    when 1 => r := "00011100";
                    when 2 => r := "00101100";
                    when 3 => r := "01001100";
                    when 4 => r := "01111110";
                    when 5 => r := "00001100";
                    when 6 => r := "00001100";
                    when others => r := "00000000";
                end case;
            when CH_5 =>
                case row is
                    when 0 => r := "01111110";
                    when 1 => r := "01100000";
                    when 2 => r := "01111100";
                    when 3 => r := "00000110";
                    when 4 => r := "00000110";
                    when 5 => r := "01100110";
                    when 6 => r := "00111100";
                    when others => r := "00000000";
                end case;
            when CH_6 =>
                case row is
                    when 0 => r := "00111100";
                    when 1 => r := "01100000";
                    when 2 => r := "01111100";
                    when 3 => r := "01100110";
                    when 4 => r := "01100110";
                    when 5 => r := "01100110";
                    when 6 => r := "00111100";
                    when others => r := "00000000";
                end case;
            when CH_7 =>
                case row is
                    when 0 => r := "01111110";
                    when 1 => r := "00000110";
                    when 2 => r := "00001100";
                    when 3 => r := "00011000";
                    when 4 => r := "00110000";
                    when 5 => r := "00110000";
                    when 6 => r := "00110000";
                    when others => r := "00000000";
                end case;
            when CH_8 =>
                case row is
                    when 0 => r := "00111100";
                    when 1 => r := "01100110";
                    when 2 => r := "01100110";
                    when 3 => r := "00111100";
                    when 4 => r := "01100110";
                    when 5 => r := "01100110";
                    when 6 => r := "00111100";
                    when others => r := "00000000";
                end case;
            when CH_9 =>
                case row is
                    when 0 => r := "00111100";
                    when 1 => r := "01100110";
                    when 2 => r := "01100110";
                    when 3 => r := "00111110";
                    when 4 => r := "00000110";
                    when 5 => r := "00001100";
                    when 6 => r := "01111000";
                    when others => r := "00000000";
                end case;
            when CH_M =>
                case row is
                    when 0 => r := "01100110";
                    when 1 => r := "01111110";
                    when 2 => r := "01111110";
                    when 3 => r := "01101010";
                    when 4 => r := "01100110";
                    when 5 => r := "01100110";
                    when 6 => r := "01100110";
                    when others => r := "00000000";
                end case;
            when CH_H =>
                case row is
                    when 0 => r := "01100110";
                    when 1 => r := "01100110";
                    when 2 => r := "01100110";
                    when 3 => r := "01111110";
                    when 4 => r := "01100110";
                    when 5 => r := "01100110";
                    when 6 => r := "01100110";
                    when others => r := "00000000";
                end case;
            when others =>
                r := "00000000";
        end case;
        return r;
    END FUNCTION;

BEGIN
    process(pixel_row, pixel_col, pause_sel, game_over, score_val, high_score_val)
        variable r, c         : integer;
        variable ch           : integer;
        variable glyph_r      : integer;
        variable glyph_c      : integer;
        variable glyph_bits   : std_logic_vector(7 downto 0);
        variable char_idx     : integer;
        variable x_off        : integer;
    begin
        r := to_integer(unsigned(pixel_row));
        c := to_integer(unsigned(pixel_col));

        if (c >= BOX_LEFT and c <= BOX_RIGHT and r >= BOX_TOP and r <= BOX_BOTTOM) then
            box_active <= '1';
        else
            box_active <= '0';
        end if;

        ch := CH_SPACE;
        glyph_r := 0;
        glyph_c := 0;

        if game_over = '1' then
            -- Game Over Screen:
            -- Line 1: "KAMU KALAH" (y=172..187, 10 chars * 20px = 200px, x=220..419)
            if (r >= 172 and r < 188) and (c >= 220 and c < 420) then
                x_off := c - 220;
                char_idx := x_off / 20;
                if (x_off mod 20) < 16 then
                    glyph_r := (r - 172) / 2;
                    glyph_c := (x_off mod 20) / 2;
                    case char_idx is
                        when 0 => ch := CH_K;
                        when 1 => ch := CH_A;
                        when 2 => ch := CH_M;
                        when 3 => ch := CH_U;
                        when 4 => ch := CH_SPACE;
                        when 5 => ch := CH_K;
                        when 6 => ch := CH_A;
                        when 7 => ch := CH_L;
                        when 8 => ch := CH_A;
                        when 9 => ch := CH_H;
                        when others => ch := CH_SPACE;
                    end case;
                end if;
            -- Line 2: "SKOR = XX" (y=220..235, 9 chars * 20px = 180px, x=230..409)
            elsif (r >= 220 and r < 236) and (c >= 230 and c < 410) then
                x_off := c - 230;
                char_idx := x_off / 20;
                if (x_off mod 20) < 16 then
                    glyph_r := (r - 220) / 2;
                    glyph_c := (x_off mod 20) / 2;
                    case char_idx is
                        when 0 => ch := CH_S;
                        when 1 => ch := CH_K;
                        when 2 => ch := CH_O;
                        when 3 => ch := CH_R;
                        when 4 => ch := CH_SPACE;
                        when 5 => ch := CH_EQ;
                        when 6 => ch := CH_SPACE;
                        when 7 => ch := digit_to_ch((score_val / 10) mod 10);
                        when 8 => ch := digit_to_ch(score_val mod 10);
                        when others => ch := CH_SPACE;
                    end case;
                end if;
            -- Line 3: "> LANJUT" (y=268..283)
            elsif (r >= 268 and r < 284) then
                glyph_r := (r - 268) / 2;
                if (c >= 216 and c < 232) then
                    ch := CH_ARROW;
                    glyph_c := (c - 216) / 2;
                elsif (c >= 248 and c < 368) then
                    x_off := c - 248;
                    char_idx := x_off / 20;
                    if (x_off mod 20) < 16 then
                        glyph_c := (x_off mod 20) / 2;
                        case char_idx is
                            when 0 => ch := CH_L;
                            when 1 => ch := CH_A;
                            when 2 => ch := CH_N;
                            when 3 => ch := CH_J;
                            when 4 => ch := CH_U;
                            when 5 => ch := CH_T;
                            when others => ch := CH_SPACE;
                        end case;
                    end if;
                end if;
            end if;
        -- Pause Menu Screen:
        -- Line 1: "P A U S E" (y = 172..187, 5 chars * 24px = 112px, x = 264..375)
        elsif (r >= 172 and r < 188) and (c >= 264 and c < 376) then
            x_off := c - 264;
            char_idx := x_off / 24;
            if (x_off mod 24) < 16 then
                glyph_r := (r - 172) / 2;
                glyph_c := (x_off mod 24) / 2;
                case char_idx is
                    when 0 => ch := CH_P;
                    when 1 => ch := CH_A;
                    when 2 => ch := CH_U;
                    when 3 => ch := CH_S;
                    when 4 => ch := CH_E;
                    when others => ch := CH_SPACE;
                end case;
            end if;

        -- Line 2: "> 1.  LANJUTKAN" (y = 232..247)
        elsif (r >= 232 and r < 248) then
            glyph_r := (r - 232) / 2;
            -- Cursor '>' at x = 160..175
            if (c >= 160 and c < 176) then
                if pause_sel = '0' then
                    ch := CH_ARROW;
                    glyph_c := (c - 160) / 2;
                end if;
            -- "1." at x = 184..215
            elsif (c >= 184 and c < 200) then
                ch := CH_1;
                glyph_c := (c - 184) / 2;
            elsif (c >= 200 and c < 216) then
                ch := CH_DOT;
                glyph_c := (c - 200) / 2;
            -- "LANJUTKAN" at x = 232..411 (9 chars * 20px)
            elsif (c >= 232 and c < 412) then
                x_off := c - 232;
                char_idx := x_off / 20;
                if (x_off mod 20) < 16 then
                    glyph_c := (x_off mod 20) / 2;
                    case char_idx is
                        when 0 => ch := CH_L;
                        when 1 => ch := CH_A;
                        when 2 => ch := CH_N;
                        when 3 => ch := CH_J;
                        when 4 => ch := CH_U;
                        when 5 => ch := CH_T;
                        when 6 => ch := CH_K;
                        when 7 => ch := CH_A;
                        when 8 => ch := CH_N;
                        when others => ch := CH_SPACE;
                    end case;
                end if;
            end if;

        -- Line 3: "  2.  ULANG" (y = 268..283)
        elsif (r >= 268 and r < 284) then
            glyph_r := (r - 268) / 2;
            -- Cursor '>' at x = 160..175
            if (c >= 160 and c < 176) then
                if pause_sel = '1' then
                    ch := CH_ARROW;
                    glyph_c := (c - 160) / 2;
                end if;
            -- "2." at x = 184..215
            elsif (c >= 184 and c < 200) then
                ch := CH_2;
                glyph_c := (c - 184) / 2;
            elsif (c >= 200 and c < 216) then
                ch := CH_DOT;
                glyph_c := (c - 200) / 2;
            -- "ULANG" at x = 232..331 (5 chars * 20px)
            elsif (c >= 232 and c < 332) then
                x_off := c - 232;
                char_idx := x_off / 20;
                if (x_off mod 20) < 16 then
                    glyph_c := (x_off mod 20) / 2;
                    case char_idx is
                        when 0 => ch := CH_U;
                        when 1 => ch := CH_L;
                        when 2 => ch := CH_A;
                        when 3 => ch := CH_N;
                        when 4 => ch := CH_G;
                        when others => ch := CH_SPACE;
                    end case;
                end if;
            end if;
        end if;

        if ch /= CH_SPACE then
            glyph_bits := get_glyph_row(ch, glyph_r);
            pixel_on <= glyph_bits(7 - glyph_c);
        else
            pixel_on <= '0';
        end if;

        -- HUD Labels & Scores (uniform 8x16 font, y=42..57):
        -- Left:  "SKOR = XX"           at x = 32..121
        -- Right: "SKOR TERTINGGI = XX" at x = 418..607
        ch := CH_SPACE;
        glyph_r := 0;
        glyph_c := 0;
        if (r >= 42 and r < 58) then
            glyph_r := (r - 42) / 2;
            if (c >= 32 and c < 122) then
                x_off := c - 32;
                char_idx := x_off / 10;
                if (x_off mod 10) < 8 then
                    glyph_c := x_off mod 10;
                    case char_idx is
                        when 0 => ch := CH_S;
                        when 1 => ch := CH_K;
                        when 2 => ch := CH_O;
                        when 3 => ch := CH_R;
                        when 4 => ch := CH_SPACE;
                        when 5 => ch := CH_EQ;
                        when 6 => ch := CH_SPACE;
                        when 7 => ch := digit_to_ch((score_val / 10) mod 10);
                        when 8 => ch := digit_to_ch(score_val mod 10);
                        when others => ch := CH_SPACE;
                    end case;
                end if;
            elsif (c >= 418 and c < 608) then
                x_off := c - 418;
                char_idx := x_off / 10;
                if (x_off mod 10) < 8 then
                    glyph_c := x_off mod 10;
                    case char_idx is
                        when 0  => ch := CH_S;
                        when 1  => ch := CH_K;
                        when 2  => ch := CH_O;
                        when 3  => ch := CH_R;
                        when 4  => ch := CH_SPACE;
                        when 5  => ch := CH_T;
                        when 6  => ch := CH_E;
                        when 7  => ch := CH_R;
                        when 8  => ch := CH_T;
                        when 9  => ch := CH_I;
                        when 10 => ch := CH_N;
                        when 11 => ch := CH_G;
                        when 12 => ch := CH_G;
                        when 13 => ch := CH_I;
                        when 14 => ch := CH_SPACE;
                        when 15 => ch := CH_EQ;
                        when 16 => ch := CH_SPACE;
                        when 17 => ch := digit_to_ch((high_score_val / 10) mod 10);
                        when 18 => ch := digit_to_ch(high_score_val mod 10);
                        when others => ch := CH_SPACE;
                    end case;
                end if;
            end if;
        end if;

        if ch /= CH_SPACE then
            glyph_bits := get_glyph_row(ch, glyph_r);
            hud_pixel_on <= glyph_bits(7 - glyph_c);
        else
            hud_pixel_on <= '0';
        end if;
    end process;
END ARCHITECTURE behavioral;

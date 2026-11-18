-- VGA_SYNC for Basys 3 (640x480 @ 60Hz with 12-bit RGB color)
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY VGASYNC IS
    PORT(
        clock_25Mhz                    : IN  STD_LOGIC;
        red, green, blue               : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        red_out, green_out, blue_out   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        horiz_sync_out, vert_sync_out  : OUT STD_LOGIC;
        video_on                       : OUT STD_LOGIC;
        pixel_row, pixel_column        : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END VGASYNC;

ARCHITECTURE a OF VGASYNC IS
    SIGNAL horiz_sync, vert_sync : STD_LOGIC := '1';
    SIGNAL video_on_int, video_on_v, video_on_h : STD_LOGIC := '0';
    SIGNAL h_count, v_count : STD_LOGIC_VECTOR(9 DOWNTO 0) := (others => '0');
BEGIN

PROCESS(clock_25Mhz)
BEGIN
    IF rising_edge(clock_25Mhz) THEN
        -- Generate Horizontal Timing Signals
        -- H_count: 0-639 Display, 640-655 Front Porch, 656-751 Sync (active low), 752-799 Back Porch
        IF (h_count = 799) THEN  
            h_count <= "0000000000";
        ELSE    
            h_count <= h_count + 1;
        END IF;

        IF (h_count <= 751) AND (h_count >= 656) THEN
            horiz_sync <= '0';
        ELSE
            horiz_sync <= '1';
        END IF;

        -- Generate Vertical Timing Signals
        -- V_count: 0-479 Display, 480-489 Front Porch, 490-491 Sync (active low), 492-520 Back Porch
        IF (v_count >= 520) AND (h_count >= 699) THEN
            v_count <= "0000000000";
        ELSIF (h_count = 699) THEN
            v_count <= v_count + 1;
        END IF;

        IF (v_count <= 491) AND (v_count >= 490) THEN
            vert_sync <= '0';
        ELSE
            vert_sync <= '1';
        END IF;

        -- Generate Video on Screen Signals for Pixel Data
        IF (h_count <= 639) THEN
            video_on_h <= '1';
            pixel_column <= h_count;
        ELSE
            video_on_h <= '0';
        END IF;

        IF (v_count <= 479) THEN
            video_on_v <= '1';
            pixel_row <= v_count;
        ELSE
            video_on_v <= '0';
        END IF;

        -- Video registers to eliminate delays / glitches
        IF (video_on_int = '1') THEN
            red_out   <= red;
            green_out <= green;
            blue_out  <= blue;
        ELSE
            red_out   <= "0000";
            green_out <= "0000";
            blue_out  <= "0000";
        END IF;

        horiz_sync_out <= horiz_sync;
        vert_sync_out  <= vert_sync;
    END IF;
END PROCESS;

-- video_on is high only when RGB data is displayed
video_on_int <= video_on_h AND video_on_v;
video_on     <= video_on_int;

END a;

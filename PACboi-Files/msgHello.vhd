LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;





ENTITY msgHello IS
 PORT ( Pixel_row: IN std_logic_vector(9 downto 0);
		   Pixel_col: IN std_logic_vector (9 downto 0);			
		  enableMsg : IN std_logic;
		  pimpclock,clk : IN STD_LOGIC; 
		  S_SWITCH, R_SWITCH, B_UP, B_DOWN, B_LEFT, B_RIGHT : IN std_logic;
	      Char_address: OUT std_logic_vector (13 downto 0);
			Char_address2: buffer std_logic_vector (7 downto 0);
	     	 Font_row: OUT std_logic_vector (3 downto 0);
		    Font_col: OUT std_logic_vector (3 downto 0)
	   );
END msgHello;

ARCHITECTURE xyz OF msgHello IS
signal win_con_pac_row : integer :=0;
signal win_con_pac_col : integer :=0;
signal win_con_ghost_row : integer :=9;
signal win_con_ghost_col : integer :=25;
signal direction : bit_vector (1 downto 0);
signal counter : bit_vector (1 downto 0);
signal char_check : integer :=0;
SIGNAL Flag : std_logic :='0';
signal pix_count_col : integer := 0;
signal my_ass_for_top : integer := 0; --signal to stop moving up
signal my_ass_for_left : integer := 0; --signal to stop moving left
signal my_pac_for_top : integer := 0; --signal to stop moving up
signal my_pac_for_left : integer := 0; --signal to stop moving left
signal pix_count_row : integer := 0;
signal threshold: integer :=0;
signal threshold2: integer :=0;
signal threshold_pac: integer := 0;
signal threshold_ghost: integer := 0;
signal ghostlock,paclock: std_logic :='0';
signal is_pacman_moving : std_logic := '0';
--signals for pacboii random movements
signal pac_row, pac_col: integer:=0;
signal clk_dir_check: integer:=0; --for random direction
signal c:std_logic_vector (7 downto 0);
signal l_f :std_logic;
signal rand_num : integer := 0;
signal loop_counter : std_logic_vector (7 downto 0);
signal isHitTopWall,isHitLeftWall,isHitBottomWall,isHitRightWall : std_logic := '0';
signal gUp,gRight,gDown,gLeft : std_logic := '0';
signal BALLCOUNT : integer := 0;
signal BALL1_UNLOCK_Value,BALL2_UNLOCK_Value,BALL3_UNLOCK_Value,BALL4_UNLOCK_Value,BALL5_UNLOCK_Value : std_logic := '0';
signal BALL6_UNLOCK_Value,BALL7_UNLOCK_Value,BALL8_UNLOCK_Value,BALL9_UNLOCK_Value,BALL10_UNLOCK_Value : std_logic := '0';
signal BALL11_UNLOCK_Value,BALL12_UNLOCK_Value,BALL13_UNLOCK_Value,BALL14_UNLOCK_Value,BALL15_UNLOCK_Value : std_logic := '0';
signal rand : bit_vector (10 downto 0) := "11001101001";
signal switch_bit : std_logic := '0';
--signal pimp_clock : std_logic := pimpclock;

function in_box (p_left, p_top, p_right, p_bottom: integer; px_row, px_col: std_logic_vector) return boolean is
begin
    return (conv_integer(px_col) >= p_left and conv_integer(px_col) <= p_right and
            conv_integer(px_row) >= p_top and conv_integer(px_row) <= p_bottom);
end function in_box;

--procedure to reset game

BEGIN

PROCESS(clk)
variable next_dir    : bit_vector(1 downto 0);
variable pacboii_row : integer := 225;
variable pacboii_col : integer := 1;
constant MAP_WALL_LEFT: integer := 48;
constant MAP_WALL_TOP: integer := 81;
constant MAP_WALL_RIGHT: integer := 592;
constant MAP_WALL_BOTTOM: integer := 384;
constant ROW_PATH1_BOTTOM: integer := 96;
constant ROW_PATH2_TOP: integer := 225;
constant ROW_PATH2_BOTTOM: integer := 240;
constant ROW_PATH3_TOP: integer := 369;
constant COL_PATH1_RIGHT: integer := 61;
constant COL_PATH2_LEFT: integer := 191;
constant COL_PATH2_RIGHT: integer := 206;
constant COL_PATH3_LEFT: integer := 334;
constant COL_PATH3_RIGHT: integer := 351;
constant COL_PATH4_LEFT: integer := 446;
constant COL_PATH4_RIGHT: integer := 463;
constant COL_PATH5_LEFT: integer := 575;
constant BALL1_top_LEFT : integer := 50;
constant BALL1_top_right: integer := 65;
constant BALL2_TOP_LEFT : integer := 194;
constant BALL2_TOP_RIGHT: integer := 209;
constant BALL3_TOP_LEFT : integer := 338;
constant BALL3_TOP_RIGHT: integer := 353;
constant BALL4_TOP_LEFT : integer := 450;
constant BALL4_TOP_RIGHT: integer := 465;
constant BALL5_TOP_LEFT : integer := 578;
constant BALL5_TOP_RIGHT: integer := 591;
constant BALL1_COL_NUM : integer:= 0;
constant BALL2_COL_NUM : integer:= 9;
constant BALL3_COL_NUM : integer:= 18;
constant BALL4_COL_NUM : integer:= 25;
constant BALL5_COL_NUM : integer:= 33;
constant BALL_ROW_1 : integer := 0;
constant BALL_ROW_2 : integer := 9;
constant BALL_ROW_3 : integer := 18;

BEGIN 
IF rising_edge(clk) THEN
IF (enableMsg = '1') THEN
-- FIRST BLANK
 IF Pixel_Col >= 1 AND Pixel_Col <= 640 AND Pixel_row >= 1 AND Pixel_row <= 16  THEN 
	Font_row <= Pixel_row(3 downto 0);
	Font_col <= Pixel_col(3 downto 0);
	Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	END IF;
-- TITLE
 IF Pixel_Col >= 236 AND Pixel_Col <= 456 AND Pixel_row >= 17 AND Pixel_row <= 32  THEN 
	Font_row <= Pixel_row(3 downto 0);
	Font_col <= Pixel_col(3 downto 0);
	IF Pixel_col >= 238 AND Pixel_Col <= 254 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (1,14); --Display "the pacboii"
	ELSIF Pixel_col >= 255 AND Pixel_Col <= 269 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (27,14); --Display "P"
	ELSIF Pixel_col >= 270 AND Pixel_Col <= 285 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (23,14); --Display "A"
	ELSIF Pixel_col >= 286 AND Pixel_Col <= 301 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (25,14); --Display "C"
	ELSIF Pixel_col >= 302 AND Pixel_Col <= 317 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (24,14); --Display "B"
	ELSIF Pixel_col >= 318 AND Pixel_Col <= 333 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (26,14); --Display "O"
	ELSIF Pixel_col >= 334 AND Pixel_Col <= 349 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (28,14); --Display "i"
	ELSIF Pixel_col >= 350 AND Pixel_Col <= 365 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (28,14); --Display "i"
	ELSIF Pixel_col >= 366 AND Pixel_Col <= 382 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (0,14); --Display " the ghost"	
	ELSE
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14); --Display " HORIZONTAL LINE "
	END IF;
 END IF;
-- SECOND BLANK
  IF Pixel_Col >= 1 AND Pixel_Col <= 640 AND Pixel_row >= 33 AND Pixel_row <= 64  THEN 
	Font_row <= Pixel_row(3 downto 0);
	Font_col <= Pixel_col(3 downto 0);
	Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	END IF;
-- START OF MAP
  IF Pixel_Col >= 1 AND Pixel_Col <= 640 AND Pixel_row >= 65 AND Pixel_row <= 80  THEN 
	Font_row <= Pixel_row(3 downto 0);
	Font_col <= Pixel_col(3 downto 0);
		IF Pixel_col >= 30 AND Pixel_Col <= 607 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14); 
	ELSE 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14); 
	END IF;
	END IF;

-- TOP PATH WITH BALLZ (592)
	IF Pixel_Col >= 1 AND Pixel_Col <= 640 AND Pixel_row >= 81 AND Pixel_row <= 96  THEN 
	Font_row <= Pixel_row(3 downto 0);
	Font_col <= Pixel_col(3 downto 0);
		IF Pixel_col >= 30 AND Pixel_Col <= 45 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14); 
	ELSIF Pixel_col >= 50 AND Pixel_Col <= 65 THEN --BALL 1
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 66 AND Pixel_Col <= 193 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 194 AND Pixel_Col <= 209 THEN --BALL 2
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 210 AND Pixel_Col <= 337 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 338 AND Pixel_Col <= 353 THEN --BALL 3
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 354 AND Pixel_Col <= 449 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 450 AND Pixel_Col <= 465 THEN --BALL 4
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 466 AND Pixel_Col <= 577 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 578 AND Pixel_Col <= 591 THEN --BALL 5
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 592 AND Pixel_Col <= 607 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14); 
	ELSE
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	END IF;
	END IF;
-- TOP OF FIRST BOX SERIES
	IF Pixel_Col >= 1 AND Pixel_Col <= 640 AND Pixel_row >= 97 AND Pixel_row <= 224  THEN 
	Font_row <= Pixel_row(3 downto 0);
	Font_col <= Pixel_col(3 downto 0);
		IF Pixel_col >= 30 AND Pixel_Col <= 45 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14); 
	ELSIF Pixel_col >= 46 AND Pixel_Col <= 63 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14); 
	ELSIF Pixel_col >= 64 AND Pixel_Col <= 189 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14);
	ELSIF Pixel_col >= 190 AND Pixel_Col <= 205 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 208 AND Pixel_Col <= 333 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14);
	ELSIF Pixel_col >= 334 AND Pixel_Col <= 349 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 352 AND Pixel_Col <= 445 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14);
	ELSIF Pixel_col >= 446 AND Pixel_Col <= 461 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 464 AND Pixel_Col <= 573 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14);
	ELSIF Pixel_col >= 576 AND Pixel_Col <= 591 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 592 AND Pixel_Col <= 607 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14);	
	ELSE
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	END IF;
	END IF;

-- SECOND MOVE PATH WITH BALLZ
	IF Pixel_Col >= 1 AND Pixel_Col <= 640 AND Pixel_row >= 225 AND Pixel_row <= 240  THEN 
	Font_row <= Pixel_row(3 downto 0);
	Font_col <= Pixel_col(3 downto 0);
		IF Pixel_col >= 30 AND Pixel_Col <= 45 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14); 
	ELSIF Pixel_col >= 50 AND Pixel_Col <= 65 THEN --BALL 1
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 66 AND Pixel_Col <= 193 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 194 AND Pixel_Col <= 209 THEN --BALL 2
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 210 AND Pixel_Col <= 337 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 338 AND Pixel_Col <= 353 THEN --BALL 3
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 354 AND Pixel_Col <= 449 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 450 AND Pixel_Col <= 465 THEN --BALL 4
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 466 AND Pixel_Col <= 577 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 578 AND Pixel_Col <= 591 THEN --BALL 5
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 592 AND Pixel_Col <= 607 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14); 
	ELSE
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	END IF;
	END IF;
-- TOP OF SECOND BOX SERIES
	IF Pixel_Col >= 1 AND Pixel_Col <= 640 AND Pixel_row >= 241 AND Pixel_row <= 368  THEN 
	Font_row <= Pixel_row(3 downto 0);
	Font_col <= Pixel_col(3 downto 0);
		IF Pixel_col >= 30 AND Pixel_Col <= 45 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14); 
	ELSIF Pixel_col >= 46 AND Pixel_Col <= 63 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14); 
	ELSIF Pixel_col >= 64 AND Pixel_Col <= 189 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14);
	ELSIF Pixel_col >= 190 AND Pixel_Col <= 205 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 208 AND Pixel_Col <= 333 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14);
	ELSIF Pixel_col >= 334 AND Pixel_Col <= 349 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 352 AND Pixel_Col <= 445 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14);
	ELSIF Pixel_col >= 446 AND Pixel_Col <= 461 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 464 AND Pixel_Col <= 573 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14);
	ELSIF Pixel_col >= 576 AND Pixel_Col <= 591 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 592 AND Pixel_Col <= 607 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14);	
	ELSE
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	END IF;
	END IF;

-- BOTTOM MOVE PATH WITH BALLZ
	IF Pixel_Col >= 1 AND Pixel_Col <= 640 AND Pixel_row >= 369 AND Pixel_row <= 384  THEN
	Font_row <= Pixel_row(3 downto 0);
	Font_col <= Pixel_col(3 downto 0);
	IF Pixel_col >= 30 AND Pixel_Col <= 45 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14); 
	ELSIF Pixel_col >= 50 AND Pixel_Col <= 65 THEN --BALL 1
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 66 AND Pixel_Col <= 193 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 194 AND Pixel_Col <= 209 THEN --BALL 2
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 210 AND Pixel_Col <= 337 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 338 AND Pixel_Col <= 353 THEN --BALL 3
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 354 AND Pixel_Col <= 449 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 450 AND Pixel_Col <= 465 THEN --BALL 4
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 466 AND Pixel_Col <= 577 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	ELSIF Pixel_col >= 578 AND Pixel_Col <= 591 THEN --BALL 5
		Char_address <= CONV_STD_LOGIC_VECTOR (13,14);
	ELSIF Pixel_col >= 592 AND Pixel_Col <= 607 THEN 
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14); 
	ELSE
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14);
	END IF;
	END IF;
-- BOTTOM OF MAP
	IF Pixel_Col >= 1 AND Pixel_Col <= 640 AND Pixel_row >= 385 AND Pixel_row <= 400  THEN 
	Font_row <= Pixel_row(3 downto 0);
	Font_col <= Pixel_col(3 downto 0);
		IF Pixel_col >= 30 AND Pixel_Col <= 607 THEN
		Char_address <= CONV_STD_LOGIC_VECTOR (31,14); 
	ELSE 
		Char_address <= CONV_STD_LOGIC_VECTOR (30,14); 
	END IF;
	END IF;

-- TIME TO START THE GAME
	if in_box(286, 44, 300, 60, pixel_Row, Pixel_Col) then
        if BALLCOUNT > 9 then
            Char_address <= CONV_STD_LOGIC_VECTOR(15, 14);
        else
            Char_address <= CONV_STD_LOGIC_VECTOR(14, 14);
        end if;
    end if;
	if in_box(301, 44, 318, 60, pixel_Row, Pixel_Col) then
        if BALLCOUNT = 0 or BALLCOUNT = 10 then
            Char_address <= CONV_STD_LOGIC_VECTOR(14, 14);
        elsif BALLCOUNT = 1 or BALLCOUNT = 11 then
            Char_address <= CONV_STD_LOGIC_VECTOR(15, 14);
        elsif BALLCOUNT = 2 or BALLCOUNT = 12 then
            Char_address <= CONV_STD_LOGIC_VECTOR(16, 14);
        elsif BALLCOUNT = 3 or BALLCOUNT = 13 then
            Char_address <= CONV_STD_LOGIC_VECTOR(17, 14);
        elsif BALLCOUNT = 4 or BALLCOUNT = 14 then
            Char_address <= CONV_STD_LOGIC_VECTOR(18, 14);
        elsif BALLCOUNT = 5 or BALLCOUNT = 15 then
            Char_address <= CONV_STD_LOGIC_VECTOR(19, 14);
        elsif BALLCOUNT = 6 then
            Char_address <= CONV_STD_LOGIC_VECTOR(20, 14);
        elsif BALLCOUNT = 7 then
            Char_address <= CONV_STD_LOGIC_VECTOR(21, 14);
        elsif BALLCOUNT = 8 then
            Char_address <= CONV_STD_LOGIC_VECTOR(22, 14);
        elsif BALLCOUNT = 9 then
            Char_address <= CONV_STD_LOGIC_VECTOR(12, 14);
        end if;
    end if;
	threshold <= threshold+1;
	threshold2 <= threshold2+1;
	--
	-- Define Movements
	--
	-- Counter controls pacman movements
	-- Direction controls ghost movements
	
	if (S_SWITCH = '1') then
		if (B_lEFT = '1') then
			counter <= "00";
			is_pacman_moving <= '1';
		elsif (B_rIGHT = '1') then
			counter <= "01";
			is_pacman_moving <= '1';
		elsif (B_up = '1') then
			counter <= "10";
			is_pacman_moving <= '1';
		elsif (B_down = '1') then
			counter <= "11";
			is_pacman_moving <= '1';
		else
			is_pacman_moving <= '0'; -- Hold-to-move: stop when button is released!
		end if;
		if ((win_con_ghost_col = 33 and win_con_ghost_row = 18) or (win_con_ghost_col = 0 and win_con_ghost_row = 18)) then
			direction <= "10";
		elsif ((win_con_ghost_col = 0 and win_con_ghost_row = 0)) then
			direction <= "11";
			switch_bit <= not switch_bit;
		elsif (win_con_ghost_row = 9 and (win_con_ghost_col = 0 or win_con_ghost_col = 9 or win_con_ghost_col = 33)) then
			direction <= rand (2 downto 1);
			switch_bit <= not switch_bit;
		elsif (win_con_ghost_row = 9 and (win_con_ghost_col = 18 or win_con_ghost_col = 25)) then
			direction <= rand (1 downto 0);
			switch_bit <= not switch_bit;
		elsif ((win_con_ghost_row = 18 and win_con_ghost_col = 9 ) or (win_con_ghost_row = 0 and win_con_ghost_col = 9) or (win_con_ghost_row = 18 and win_con_ghost_col = 25)) then
			direction <= "01";
			switch_bit <= not switch_bit;
		elsif ((win_con_ghost_row = 0 and win_con_ghost_col = 25)) then
				if switch_bit = '1' then
					direction <= "00";
				else
					direction <= "11";
				end if;
		elsif (win_con_ghost_row = 18 and win_con_ghost_col = 18) then
				if switch_bit = '1' then
					direction <= "01";
				else
					direction <= "00";
				end if;
		elsif (win_con_ghost_col = 33 and win_con_ghost_row = 0) then
			direction <= "00";
			switch_bit <= not switch_bit;
		elsif (win_con_ghost_col = 18 and win_con_ghost_row = 0) then
				if switch_bit = '1' then
					direction <= "00";
				else
					direction <= "11";
				end if;
		end if;
	--Now to control Ghostie
	else
		if (B_lEFT = '1') then
			direction <= "00";
		elsif (B_rIGHT = '1') then
			direction <= "01";
		elsif (B_up = '1') then
			direction <= "10";
		elsif (B_down = '1') then
			direction <= "11";
		end if;
		if ((win_con_pac_col = 33 and win_con_pac_row = 18) or (win_con_pac_col = 0 and win_con_pac_row = 18)) then
			counter <= "10";
		elsif ((win_con_pac_col = 0 and win_con_pac_row = 0)) then
			counter <= "11";
			switch_bit <= not switch_bit;
		elsif (win_con_pac_row = 9 and (win_con_pac_col = 0 or win_con_pac_col = 9 or win_con_pac_col = 33)) then
			counter <= rand (2 downto 1);
			switch_bit <= not switch_bit;
		elsif (win_con_pac_row = 9 and (win_con_pac_col = 18 or win_con_pac_col = 25)) then
			counter <= rand (1 downto 0);
			switch_bit <= not switch_bit;
		elsif ((win_con_pac_row = 18 and win_con_pac_col = 9 ) or (win_con_pac_row = 0 and win_con_pac_col = 9) or (win_con_pac_row = 18 and win_con_pac_col = 25)) then
			counter <= "01";
			switch_bit <= not switch_bit;
		elsif ((win_con_pac_row = 0 and win_con_pac_col = 25)) then
			if switch_bit = '1' then
				counter <= "00";
			else
				counter <= "11";
			end if;
		elsif (win_con_pac_row = 18 and win_con_pac_col = 18) then
			if switch_bit = '1' then
				counter <= "01";
			else
				counter <= "00";
			end if;
		elsif (win_con_pac_col = 33 and win_con_pac_row = 0) then
			counter <= "00";
			switch_bit <= not switch_bit;
		elsif (win_con_pac_col = 18 and win_con_pac_row = 0) then
			if switch_bit = '1' then
				counter <= "00";
			else
				counter <= "11";
			end if;
		end if;
	end if;
	--
	--Pacman Controller
	--
	
	if threshold2 >= 25000000 then
		rand <= rand rol 1;
		threshold2 <= 0;
	end if;
	threshold_pac <= threshold_pac + 1;
	if threshold_pac >= 5000000 then 
		threshold_pac <= 0;
		paclock <= not paclock;

	-- Precise grid collision & Hold-to-Move controller
		if (is_pacman_moving = '1') then
			-- Moving LEFT
			if (counter = "00") then
				if (pac_col > 0) and (pac_row = 0 or pac_row = 144 or pac_row = 288) then
					pac_col <= pac_col - 16;
					my_pac_for_left <= my_pac_for_left - 16;
					win_con_pac_col <= win_con_pac_col - 1;
				end if;
			-- Moving RIGHT
			elsif (counter = "01") then
				if (pac_col < 528) and (pac_row = 0 or pac_row = 144 or pac_row = 288) then
					pac_col <= pac_col + 16;
					my_pac_for_left <= my_pac_for_left + 16;
					win_con_pac_col <= win_con_pac_col + 1;
				end if;
			-- Moving UP
			elsif (counter = "10") then
				if (pac_row > 0) and (pac_col = 0 or pac_col = 144 or pac_col = 288 or pac_col = 400 or pac_col = 528) then
					pac_row <= pac_row - 16;
					my_pac_for_top <= my_pac_for_top - 16;
					win_con_pac_row <= win_con_pac_row - 1;
				end if;
			-- Moving DOWN
			elsif (counter = "11") then
				if (pac_row < 288) and (pac_col = 0 or pac_col = 144 or pac_col = 288 or pac_col = 400 or pac_col = 528) then
					pac_row <= pac_row + 16;
					my_pac_for_top <= my_pac_for_top + 16;
					win_con_pac_row <= win_con_pac_row + 1;
				end if;
			end if;
		end if;

		--Resetting threshold
		threshold <= 0;
	end if;
	if ghostlock = '1' then --draw ghost and pacboii
		if in_box(COL_PATH4_LEFT+pix_count_col, ROW_PATH2_TOP+pix_count_row, COL_PATH4_RIGHT+pix_count_col, ROW_PATH2_BOTTOM+pix_count_row, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
	end if;
	if paclock = '1' then --draw ghost and pacboii
		if in_box(MAP_WALL_LEFT+pac_col, MAP_WALL_TOP+pac_row, COL_PATH1_RIGHT+pac_col, ROW_PATH1_BOTTOM+pac_row, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
	end if;
	--
	--
	--
	-- WIN THE GAME HERE 1 / GHOST CATCHES PACMAN (INSTANT RESET)
	if (
		-- 1. Exact grid tile match
		(win_con_ghost_row = win_con_pac_row and win_con_ghost_col = win_con_pac_col)
		or
		-- 2. Same row and adjacent / leapfrogging (distance <= 1)
		(win_con_ghost_row = win_con_pac_row and 
		 (win_con_ghost_col - win_con_pac_col >= -1 and win_con_ghost_col - win_con_pac_col <= 1))
		or
		-- 3. Same column and adjacent / leapfrogging (distance <= 1)
		(win_con_ghost_col = win_con_pac_col and 
		 (win_con_ghost_row - win_con_pac_row >= -1 and win_con_ghost_row - win_con_pac_row <= 1))
		or
		-- 4. Screen bounding box overlap (with 4px margin)
		((MAP_WALL_LEFT + pac_col - 4) <= (COL_PATH4_RIGHT + pix_count_col) and
		 (COL_PATH1_RIGHT + pac_col + 4) >= (COL_PATH4_LEFT + pix_count_col) and
		 (MAP_WALL_TOP + pac_row - 4) <= (ROW_PATH2_BOTTOM + pix_count_row) and
		 (ROW_PATH1_BOTTOM + pac_row + 4) >= (ROW_PATH2_TOP + pix_count_row))
	) then
	win_con_ghost_row <= 9;
	win_con_ghost_col <= 25;
	win_con_pac_col <= 0;
	win_con_pac_row <= 0;
		pix_count_row<=0;
		pix_count_col<=0;
		my_ass_for_left<=0;
		my_ass_for_top<=0;
		pac_row<=0;
		pac_col<=0;
		my_pac_for_left<=0;
		my_pac_for_top<=0;
		pac_started <= '0';
		pac_current_dir <= "01";
		pac_desired_dir <= "01";
		gLeft<='0';gUp<='0';gRight<='0';gDown<='0';
BALL1_UNLOCK_Value <= '0';
BALL2_UNLOCK_Value <= '0';
BALL3_UNLOCK_Value <= '0';
BALL4_UNLOCK_Value <= '0';
BALL5_UNLOCK_Value <= '0';
BALL6_UNLOCK_Value <= '0';
BALL7_UNLOCK_Value <= '0';
BALL8_UNLOCK_Value <= '0';
BALL9_UNLOCK_Value <= '0';
BALL10_UNLOCK_Value <= '0';
BALL11_UNLOCK_Value <= '0';
BALL12_UNLOCK_Value <= '0';
BALL13_UNLOCK_Value <= '0';
BALL14_UNLOCK_Value <= '0';
BALL15_UNLOCK_Value <= '0';
BALLCOUNT <= 0;
	end if;
	-- RESET THE GAME HERE 1
	if (R_SWITCH ='1') then --reset game to default start position
		win_con_ghost_row <= 9;
		win_con_ghost_col <= 25;
		win_con_pac_col <= 0;
		win_con_pac_row <= 0;
		pix_count_row<=0;
		pix_count_col<=0;
		my_ass_for_left<=0;
		my_ass_for_top<=0;
		pac_row<=0;
		pac_col<=0;
		gLeft<='0';gUp<='0';gRight<='0';gDown<='0';
		--char_check <=0;
		if in_box(COL_PATH4_LEFT+pix_count_col, ROW_PATH2_TOP+pix_count_row, COL_PATH4_RIGHT+pix_count_col, ROW_PATH2_BOTTOM+pix_count_row, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
		if in_box(MAP_WALL_LEFT+pac_col, MAP_WALL_TOP+pac_row, COL_PATH1_RIGHT+pac_col, ROW_PATH1_BOTTOM+pac_row, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
	BALL1_UNLOCK_Value <= '0';
BALL2_UNLOCK_Value <= '0';
BALL3_UNLOCK_Value <= '0';
BALL4_UNLOCK_Value <= '0';
BALL5_UNLOCK_Value <= '0';
BALL6_UNLOCK_Value <= '0';
BALL7_UNLOCK_Value <= '0';
BALL8_UNLOCK_Value <= '0';
BALL9_UNLOCK_Value <= '0';
BALL10_UNLOCK_Value <= '0';
BALL11_UNLOCK_Value <= '0';
BALL12_UNLOCK_Value <= '0';
BALL13_UNLOCK_Value <= '0';
BALL14_UNLOCK_Value <= '0';
BALL15_UNLOCK_Value <= '0';
	end if;
--	end if;
end if;
		--
		--
		--
		--
		--
		--
		--
		--
		--
		--
		--
	threshold_ghost <= threshold_ghost+1;
	--
	-- Ghost Controller
	--
	if threshold_ghost >= 5000000 then 
		threshold_ghost <= 0;
		ghostlock <= not ghostlock;

	-- Precise grid collision & Hold-to-Move controller
		if (is_pacman_moving = '1') then
			-- Moving LEFT
			if (counter = "00") then
				if (pac_col > 0) and (pac_row = 0 or pac_row = 144 or pac_row = 288) then
					pac_col <= pac_col - 16;
					my_pac_for_left <= my_pac_for_left - 16;
					win_con_pac_col <= win_con_pac_col - 1;
				end if;
			-- Moving RIGHT
			elsif (counter = "01") then
				if (pac_col < 528) and (pac_row = 0 or pac_row = 144 or pac_row = 288) then
					pac_col <= pac_col + 16;
					my_pac_for_left <= my_pac_for_left + 16;
					win_con_pac_col <= win_con_pac_col + 1;
				end if;
			-- Moving UP
			elsif (counter = "10") then
				if (pac_row > 0) and (pac_col = 0 or pac_col = 144 or pac_col = 288 or pac_col = 400 or pac_col = 528) then
					pac_row <= pac_row - 16;
					my_pac_for_top <= my_pac_for_top - 16;
					win_con_pac_row <= win_con_pac_row - 1;
				end if;
			-- Moving DOWN
			elsif (counter = "11") then
				if (pac_row < 288) and (pac_col = 0 or pac_col = 144 or pac_col = 288 or pac_col = 400 or pac_col = 528) then
					pac_row <= pac_row + 16;
					my_pac_for_top <= my_pac_for_top + 16;
					win_con_pac_row <= win_con_pac_row + 1;
				end if;
			end if;
		end if;
		--Resetting threshold
		threshold <= 0;
	end if;
	if ghostlock = '1' then --draw ghost and pacboii
		if in_box(COL_PATH4_LEFT+pix_count_col, ROW_PATH2_TOP+pix_count_row, COL_PATH4_RIGHT+pix_count_col, ROW_PATH2_BOTTOM+pix_count_row, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
	end if;
	if paclock = '1' then --draw ghost and pacboii
		if in_box(MAP_WALL_LEFT+pac_col, MAP_WALL_TOP+pac_row, COL_PATH1_RIGHT+pac_col, ROW_PATH1_BOTTOM+pac_row, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
	end if;
			--
			--OUR BALLZ
		--BALL 1
		if ((win_con_pac_row = balL_ROW_1) AND (win_con_pac_col = balL1_COL_NUM)) OR BALL1_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_1) AND (win_con_pac_col = balL1_COL_NUM)) then
				if in_box(Ball1_top_LEFT-3, 81, balL1_top_right-2, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_1) AND (win_con_ghost_col = balL1_COL_NUM)) then
				if in_box(Ball1_top_LEFT-3, 81, balL1_top_right, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(Ball1_top_LEFT, 81, balL1_top_right, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL1_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL1_UNLOCK_Value <= '1';
		end if;
		--BALL 2
		if ((win_con_pac_row = balL_ROW_1) AND (win_con_pac_col = balL2_COL_NUM)) OR BALL2_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_1) AND (win_con_pac_col = balL2_COL_NUM)) then
				if in_box(Ball2_top_LEFT, 81, balL2_top_right, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_1) AND (win_con_ghost_col = balL2_COL_NUM)) then
				if in_box(Ball2_top_LEFT-3, 81, balL2_top_right, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(BALL2_TOP_LEFT, 81, BALL2_TOP_RIGHT, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL2_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL2_UNLOCK_Value <= '1';
		end if;
		--BALL 3
		if ((win_con_pac_row = balL_ROW_1) AND (win_con_pac_col = balL3_COL_NUM)) OR BALL3_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_1) AND (win_con_pac_col = balL3_COL_NUM)) then
				if in_box(Ball3_top_LEFT, 81, balL3_top_right, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_1) AND (win_con_ghost_col = balL3_COL_NUM)) then
				if in_box(Ball3_top_LEFT-3, 81, balL3_top_right, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(Ball3_top_LEFT, 81, balL3_top_right, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL3_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL3_UNLOCK_Value <= '1';
		end if;
		--BALL 4
		if ((win_con_pac_row = balL_ROW_1) AND (win_con_pac_col = balL4_COL_NUM)) OR BALL4_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_1) AND (win_con_pac_col = balL4_COL_NUM)) then
				if in_box(Ball4_top_LEFT, 81, balL1_top_right, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_1) AND (win_con_ghost_col = balL4_COL_NUM)) then
				if in_box(Ball4_top_LEFT-3, 81, balL4_top_right, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(BALL4_TOP_LEFT, 81, BALL4_TOP_RIGHT, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL4_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL4_UNLOCK_Value <= '1';
		end if;
		--BALL 5
		if ((win_con_pac_row = balL_ROW_1) AND (win_con_pac_col = balL5_COL_NUM)) OR BALL5_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_1) AND (win_con_pac_col = balL5_COL_NUM)) then
				if in_box(Ball5_top_LEFT, 81, balL5_top_right, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_1) AND (win_con_ghost_col = balL5_COL_NUM)) then
				if in_box(Ball5_top_LEFT-3, 81, balL5_top_right, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(Ball5_top_LEFT, 81, balL5_top_right, 96, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL5_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL5_UNLOCK_Value <= '1';
		end if;
		-- BALL 6
		if ((win_con_pac_row = balL_ROW_2) AND (win_con_pac_col = balL1_COL_NUM)) OR BALL6_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_2) AND (win_con_pac_col = balL1_COL_NUM)) then
				if in_box(Ball1_top_LEFT, 225, balL1_top_right, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_2) AND (win_con_ghost_col = balL1_COL_NUM)) then
				if in_box(Ball1_top_LEFT-3, 225, balL1_top_right, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(Ball1_top_LEFT, 225, balL1_top_right, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL6_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL6_UNLOCK_Value <= '1';
		end if;
		-- BALL 7
		if ((win_con_pac_row = balL_ROW_2) AND (win_con_pac_col = balL2_COL_NUM)) OR BALL7_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_2) AND (win_con_pac_col = balL2_COL_NUM)) then
				if in_box(Ball2_top_LEFT, 225, balL2_top_right, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_2) AND (win_con_ghost_col = balL2_COL_NUM)) then
				if in_box(Ball2_top_LEFT-3, 225, balL2_top_right, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(BALL2_TOP_LEFT, 225, BALL2_TOP_RIGHT, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL7_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL7_UNLOCK_Value <= '1';
		end if;
		-- BALL 8
		if ((win_con_pac_row = balL_ROW_2) AND (win_con_pac_col = balL3_COL_NUM)) OR BALL8_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_2) AND (win_con_pac_col = balL3_COL_NUM)) then
				if in_box(Ball3_top_LEFT, 225, balL3_top_right, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_2) AND (win_con_ghost_col = balL3_COL_NUM)) then
				if in_box(Ball3_top_LEFT-3, 225, balL3_top_right, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(Ball3_top_LEFT, 225, balL3_top_right, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL8_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL8_UNLOCK_Value <= '1';
		end if;
		-- BALL 9
		if ((win_con_pac_row = balL_ROW_2) AND (win_con_pac_col = balL4_COL_NUM)) OR BALL9_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_2) AND (win_con_pac_col = balL4_COL_NUM)) then
				if in_box(Ball4_top_LEFT, 225, balL1_top_right, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_2) AND (win_con_ghost_col = balL4_COL_NUM)) then
				if in_box(Ball4_top_LEFT-3, 225, balL4_top_right, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(BALL4_TOP_LEFT, 225, BALL4_TOP_RIGHT, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL9_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL9_UNLOCK_Value <= '1';
		end if;
		-- BALL 10
		if ((win_con_pac_row = balL_ROW_2) AND (win_con_pac_col = balL5_COL_NUM)) OR BALL10_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_2) AND (win_con_pac_col = balL5_COL_NUM)) then
				if in_box(Ball5_top_LEFT, 225, balL5_top_right, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_2) AND (win_con_ghost_col = balL5_COL_NUM)) then
				if in_box(Ball5_top_LEFT-3, 225, balL5_top_right, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(Ball5_top_LEFT, 225, balL5_top_right, 240, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL10_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL10_UNLOCK_Value <= '1';
		end if;
		-- BALL 11
		if ((win_con_pac_row = balL_ROW_3) AND (win_con_pac_col = balL1_COL_NUM)) OR BALL11_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_3) AND (win_con_pac_col = balL1_COL_NUM)) then
				if in_box(Ball1_top_LEFT, 369, balL1_top_right, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_3) AND (win_con_ghost_col = balL1_COL_NUM)) then
				if in_box(Ball1_top_LEFT-3, 369, balL1_top_right, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(Ball1_top_LEFT, 369, balL1_top_right, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL11_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL11_UNLOCK_Value <= '1';
		end if;
		-- BALL 12
		if ((win_con_pac_row = balL_ROW_3) AND (win_con_pac_col = balL2_COL_NUM)) OR BALL12_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_3) AND (win_con_pac_col = balL2_COL_NUM)) then
				if in_box(Ball2_top_LEFT, 369, balL2_top_right, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_3) AND (win_con_ghost_col = balL2_COL_NUM)) then
				if in_box(Ball2_top_LEFT-3, 369, balL2_top_right, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(BALL2_TOP_LEFT, 369, BALL2_TOP_RIGHT, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL12_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL12_UNLOCK_Value <= '1';
		end if;
		-- BALL 13
		if ((win_con_pac_row = balL_ROW_3) AND (win_con_pac_col = balL3_COL_NUM)) OR BALL13_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_3) AND (win_con_pac_col = balL3_COL_NUM)) then
				if in_box(Ball3_top_LEFT, 369, balL3_top_right, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_3) AND (win_con_ghost_col = balL3_COL_NUM)) then
				if in_box(Ball3_top_LEFT-3, 369, balL3_top_right, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(Ball3_top_LEFT, 369, balL3_top_right, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL13_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL13_UNLOCK_Value <= '1';
		end if;
		-- BALL 14
		if ((win_con_pac_row = balL_ROW_3) AND (win_con_pac_col = balL4_COL_NUM)) OR BALL14_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_3) AND (win_con_pac_col = balL4_COL_NUM)) then
				if in_box(Ball4_top_LEFT, 369, balL1_top_right, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_3) AND (win_con_ghost_col = balL4_COL_NUM)) then
				if in_box(Ball4_top_LEFT-3, 369, balL4_top_right, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(BALL4_TOP_LEFT, 369, BALL4_TOP_RIGHT, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL14_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL14_UNLOCK_Value <= '1';
		end if;
		-- BALL 15
		if ((win_con_pac_row = balL_ROW_3) AND (win_con_pac_col = balL5_COL_NUM)) OR BALL15_UNLOCK_Value = '1' then
			if ((win_con_pac_row = balL_ROW_3) AND (win_con_pac_col = balL5_COL_NUM)) then
				if in_box(Ball5_top_LEFT, 369, balL5_top_right, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
			elsif ((win_con_ghost_row = balL_ROW_3) AND (win_con_ghost_col = balL5_COL_NUM)) then
				if in_box(Ball5_top_LEFT-3, 369, balL5_top_right, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
			else
				if in_box(Ball5_top_LEFT, 369, balL5_top_right, 384, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(30,14); end if;
			end if;
			if BALL15_UNLOCK_Value = '0' then
				BALLCOUNT <= BALLCOUNT + 1;
			end if;
			BALL15_UNLOCK_Value <= '1';
		end if;
		
-- WIN 2 BECAUSE IDK WHY IT WORKS THOUGH
	if (
		BALLCOUNT = 15
		or
		-- 1. Exact grid tile match
		(win_con_ghost_row = win_con_pac_row and win_con_ghost_col = win_con_pac_col)
		or
		-- 2. Same row and adjacent / leapfrogging (distance <= 1)
		(win_con_ghost_row = win_con_pac_row and 
		 (win_con_ghost_col - win_con_pac_col >= -1 and win_con_ghost_col - win_con_pac_col <= 1))
		or
		-- 3. Same column and adjacent / leapfrogging (distance <= 1)
		(win_con_ghost_col = win_con_pac_col and 
		 (win_con_ghost_row - win_con_pac_row >= -1 and win_con_ghost_row - win_con_pac_row <= 1))
		or
		-- 4. Screen bounding box overlap (with 4px margin)
		((MAP_WALL_LEFT + pac_col - 4) <= (COL_PATH4_RIGHT + pix_count_col) and
		 (COL_PATH1_RIGHT + pac_col + 4) >= (COL_PATH4_LEFT + pix_count_col) and
		 (MAP_WALL_TOP + pac_row - 4) <= (ROW_PATH2_BOTTOM + pix_count_row) and
		 (ROW_PATH1_BOTTOM + pac_row + 4) >= (ROW_PATH2_TOP + pix_count_row))
	) then
	win_con_ghost_row <= 9;
	win_con_ghost_col <= 25;
	win_con_pac_col <= 0;
	win_con_pac_row <= 0;
		pix_count_row<=0;
		pix_count_col<=0;
		my_ass_for_left<=0;
		my_ass_for_top<=0;
		pac_row<=0;
		pac_col<=0;
		my_pac_for_left<=0;
		my_pac_for_top<=0;
		pac_started <= '0';
		pac_current_dir <= "01";
		pac_desired_dir <= "01";
		gLeft<='0';gUp<='0';gRight<='0';gDown<='0';
BALL1_UNLOCK_Value <= '0';
BALL2_UNLOCK_Value <= '0';
BALL3_UNLOCK_Value <= '0';
BALL4_UNLOCK_Value <= '0';
BALL5_UNLOCK_Value <= '0';
BALL6_UNLOCK_Value <= '0';
BALL7_UNLOCK_Value <= '0';
BALL8_UNLOCK_Value <= '0';
BALL9_UNLOCK_Value <= '0';
BALL10_UNLOCK_Value <= '0';
BALL11_UNLOCK_Value <= '0';
BALL12_UNLOCK_Value <= '0';
BALL13_UNLOCK_Value <= '0';
BALL14_UNLOCK_Value <= '0';
BALL15_UNLOCK_Value <= '0';
BALLCOUNT <= 0;
	end if;
	if (R_SWITCH ='1') then --reset game to default start position
		win_con_ghost_row <= 9;
		win_con_ghost_col <= 25;
		win_con_pac_col <= 0;
		win_con_pac_row <= 0;
		pix_count_row<=0;
		pix_count_col<=0;
		my_ass_for_left<=0;
		my_pac_for_left<=0;
		my_pac_for_top<=0;
		my_ass_for_top<=0;
		pac_row<=0;
		pac_col<=0;
		gLeft<='0';gUp<='0';gRight<='0';gDown<='0';
		--char_check <=0;
		if in_box(COL_PATH4_LEFT+pix_count_col, ROW_PATH2_TOP+pix_count_row, COL_PATH4_RIGHT+pix_count_col, ROW_PATH2_BOTTOM+pix_count_row, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(0,14); end if;
		if in_box(MAP_WALL_LEFT+pac_col, MAP_WALL_TOP+pac_row, COL_PATH1_RIGHT+pac_col, ROW_PATH1_BOTTOM+pac_row, pixel_Row, pixel_Col) then Char_address <= CONV_STD_LOGIC_VECTOR(1,14); end if;
BALL1_UNLOCK_Value <= '0';
BALL2_UNLOCK_Value <= '0';
BALL3_UNLOCK_Value <= '0';
BALL4_UNLOCK_Value <= '0';
BALL5_UNLOCK_Value <= '0';
BALL6_UNLOCK_Value <= '0';
BALL7_UNLOCK_Value <= '0';
BALL8_UNLOCK_Value <= '0';
BALL9_UNLOCK_Value <= '0';
BALL10_UNLOCK_Value <= '0';
BALL11_UNLOCK_Value <= '0';
BALL12_UNLOCK_Value <= '0';
BALL13_UNLOCK_Value <= '0';
BALL14_UNLOCK_Value <= '0';
BALL15_UNLOCK_Value <= '0';
BALLCOUNT <= 0;
	end if;
    END IF; -- rising_edge(clk)
END PROCESS;
END;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;
USE ieee.std_logic_unsigned.all;
package tail_package IS

type tail_x is array (7 downto 0) of STD_LOGIC_VECTOR(10 downto 0);
type tail_y is array (7 downto 0) of STD_LOGIC_VECTOR(8 downto 0);

end tail_package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;
USE ieee.std_logic_unsigned.all;
use tail_package.all;

--------------------------------------------------------------------------------
--------- vga
--------------------------------------------------------------------------------
entity monitor is
  Port ( clk_50MHz : in  STD_LOGIC;
   RESET : in  STD_LOGIC;
	-- heads position
	snake_1_x : in STD_LOGIC_VECTOR(10 downto 0);
	snake_1_y : in STD_LOGIC_VECTOR(8 downto 0);
	snake_2_x : in STD_LOGIC_VECTOR(10 downto 0);
	snake_2_y : in STD_LOGIC_VECTOR(8 downto 0);
	-- apple
	apple_x : in STD_LOGIC_VECTOR(10 downto 0);
	apple_y : in STD_LOGIC_VECTOR(8 downto 0);
	-- tail
	tail_1_x : tail_x;
	tail_1_y : tail_y;
	tail_2_x : tail_x;
	tail_2_y : tail_y;
	---------------
	hsync : out  STD_LOGIC;
	vsync : out  STD_LOGIC;
	KOLOR : out STD_LOGIC_VECTOR(8 downto 0));
end monitor;

architecture monitor_arch of monitor is

signal lin,kol : std_logic_vector (10 downto 0);

begin

	hsync <= '0' when (kol>=1305 and kol<1494) else '1';
	vsync <= '1' when (lin>=413 and lin<415) else '0';
	
	DRAWING : PROCESS(clk_50MHz, lin, kol )
	begin
		if( kol>=1281 or lin>=400 ) then
			kolor <= "000000000";
		else 
			if( kol>snake_1_x-10 and kol<snake_1_x+10 and lin>snake_1_y-10 and lin<snake_1_y+10 ) then
				kolor <= "111000000"; -- snake 1 head
			elsif( kol>snake_2_x-10 and kol<snake_2_x+10 and lin>snake_2_y-10 and lin<snake_2_y+10 ) then
				kolor <= "000111000"; -- snake 1 head
			elsif( kol>apple_x-10   and kol<apple_x+10   and lin>apple_y-10   and lin<apple_y+10 ) then
				kolor <= "000000111";
			else 
				kolor <= "000000000";
				
				for i in 7 downto 0 loop
					if( (kol>tail_1_x(i)-10   and kol<tail_1_x(i)+10   and lin>tail_1_y(i)-10   and lin<tail_1_y(i)+10 )
					  or (kol>tail_2_x(i)-10   and kol<tail_2_x(i)+10   and lin>tail_2_y(i)-10   and lin<tail_2_y(i)+10) ) then
					  kolor <= "111111000";
					  exit;
					end if;
				end loop;
			end if;
			
		end if;
	
	end process;
				 ---
				 
--------------------------------------------------------------------------------
	process (clk_50MHz,RESET)
	 begin
	  if (RESET = '0') then
	     lin <= (others=>'0');
		 kol <= (others=>'0');
	  elsif (rising_edge(clk_50MHz)) then 
	      kol <= kol + 1;
		  if (kol = 1588) then --1589 -1	  
	        kol <= (others=>'0');
		    lin <= lin + 1;
		    if (lin = 448) then --449-1 
			    lin <= (others=>'0');
		    end if;
	     end if;
	  end if;
	end process;
	
end monitor_arch;
------------------------------------------------------------------------------
---------------- KLAWIATURA
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity klawiatura is
  port ( clk_50MHz : in  STD_LOGIC;
    RESET : in  STD_LOGIC;
	 keyb_clk : in  STD_LOGIC;
    keyb_data : in  STD_LOGIC;	  
	 znak_klw : out STD_LOGIC_VECTOR(7 downto 0));		  
end klawiatura;

architecture klawiatura_arch of klawiatura is

signal dane : STD_LOGIC_VECTOR(10 downto 0);
signal nr_bitu : STD_LOGIC_VECTOR(3 downto 0);
signal minWatchdog : STD_LOGIC_VECTOR(11 downto 0);
signal key_clk_sr : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin
  process (clk_50MHz, RESET)
   begin
	 if (RESET = '0') then
		minWatchdog <= (others => '0');
	   dane <= (others=>'0');
	   nr_bitu <= (others=>'0');
	 elsif ( rising_edge(clk_50MHz) ) then
	   key_clk_sr <= key_clk_sr(2 downto 0) & keyb_clk;
	   if( minWatchdog > 0 ) then
			minWatchdog <= minWatchdog + 1; 
		end if;
	   if( minWatchdog > 6000 ) then
			--reset
			minWatchdog <= (others => '0');
			nr_bitu <= (others=>'0');
		elsif (key_clk_sr = "1100") then
			if( nr_bitu = "0000" ) then
				minWatchdog <= "000000000001"; --start watchod
			end if;
			nr_bitu <= nr_bitu + 1;
			dane <= keyb_data & dane(10 downto 1);	
			if (nr_bitu = "1010") then
	--	if (dane(8) = not (dane(7) xor dane(6) xor dane(5) xor dane(4) xor dane(3) xor dane(2) xor dane(1) xor dane(0))) then
			  znak_klw <= dane(9 downto 2);
			  nr_bitu <= (others=>'0');
			  minWatchdog <= (others=>'0');
			end if;
		end if;
	end if;
  end process;	

end klawiatura_arch;

------------------------------------------------------------------------------
---------------- KLAWIATURA --zwykla
------------------------------------------------------------------------------
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
--entity klawiatura is
--  port ( clk_50MHz : in  STD_LOGIC;
--    RESET : in  STD_LOGIC;
--	 keyb_clk : in  STD_LOGIC;
--    keyb_data : in  STD_LOGIC;	  
--	 znak_klw : out STD_LOGIC_VECTOR(7 downto 0));		  
--end klawiatura;
--
--architecture klawiatura_arch of klawiatura is
--
--signal dane : STD_LOGIC_VECTOR(10 downto 0);
--signal nr_bitu : STD_LOGIC_VECTOR(3 downto 0);
--
--begin
--  process (clk_50MHz, RESET)
--   begin
--	 if (RESET = '0') then
--	   dane <= (others=>'0');
--	   nr_bitu <= (others=>'0');
--    elsif (keyb_clk'event and keyb_clk='0') then
--	   nr_bitu <= nr_bitu + 1;
--	   dane <= keyb_data & dane(10 downto 1);	
--	   if (nr_bitu = "1010") then
----	if (dane(8) = not (dane(7) xor dane(6) xor dane(5) xor dane(4) xor dane(3) xor dane(2) xor dane(1) xor dane(0))) then
--	     znak_klw <= dane(9 downto 2);
--	     nr_bitu <= (others=>'0');
--	   end if;
--	 end if;
--  end process;	
--
--end klawiatura_arch;

--------------------------------------------------------------------------------
--------- Random generator
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity random is
port (
      clk : in std_logic;
      random_num : out std_logic_vector (10 downto 0)   --output vector            
    );
end random;

architecture random_arch of random is
begin
	process(clk)
		variable rand_temp : std_logic_vector(10 downto 0):=(10 => '1',others => '0');
		variable temp : std_logic := '0';
	begin
		if(rising_edge(clk)) then
			temp := rand_temp(10) xor rand_temp(9);
			rand_temp(10 downto 1) := rand_temp(9 downto 0);
			rand_temp(0) := temp;
		end if;
		random_num <= rand_temp;
	end process;
	
end random_arch;

--------------------------------------------------------------------------------
------------------ UKLAD GLOWNY
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
use tail_package.all;

entity vga_01 is
  Port ( clk_50MHz : in  STD_LOGIC;
   RESET : in  STD_LOGIC;
	keyb_clk : in  STD_LOGIC;
   keyb_data : in  STD_LOGIC;
	keyb_clk2 : in  STD_LOGIC;
   keyb_data2 : in  STD_LOGIC;	
	hsync : out  STD_LOGIC;
	vsync : out  STD_LOGIC;
	KOLOR : out STD_LOGIC_VECTOR(8 downto 0) );
end vga_01;

architecture vga_arch of vga_01 is

component klawiatura
  port ( clk_50MHz : in  STD_LOGIC;
   RESET : in  STD_LOGIC;
	keyb_clk : in  STD_LOGIC;
   keyb_data : in STD_LOGIC;
	znak_klw : out STD_LOGIC_VECTOR(7 downto 0));	  
end component;

component monitor
  Port ( clk_50MHz : in  STD_LOGIC;
	RESET : in  STD_LOGIC;
	-- heads position
	snake_1_x : in STD_LOGIC_VECTOR(10 downto 0);
	snake_1_y : in STD_LOGIC_VECTOR(8 downto 0);
	snake_2_x : in STD_LOGIC_VECTOR(10 downto 0);
	snake_2_y : in STD_LOGIC_VECTOR(8 downto 0);
	-- apple
	apple_x : in STD_LOGIC_VECTOR(10 downto 0);
	apple_y : in STD_LOGIC_VECTOR(8 downto 0);
	-- tail
	tail_1_x : tail_x;
	tail_1_y : tail_y;
	tail_2_x : tail_x;
	tail_2_y : tail_y;
	---------------
	hsync : out  STD_LOGIC;
	vsync : out  STD_LOGIC;
	KOLOR : out STD_LOGIC_VECTOR(8 downto 0));
end component;

component random is
port (
      clk : in std_logic;
      random_num : out std_logic_vector (10 downto 0)   --output vector            
    );
end component;
---------------------- 
--- PROCEDURY 
----------------------

procedure make_move (
	signal direction : in STD_LOGIC_VECTOR(1 downto 0);
	signal positionX : inout STD_LOGIC_VECTOR(10 downto 0);
	signal positionY : inout STD_LOGIC_VECTOR( 8 downto 0)
) is 
begin
	if (direction = "01") then
		 positionX <= positionX + 20; --prawo
	elsif (direction = "11") then
		 positionX <= positionX - 20; --lewo
	elsif (direction = "10") then
		 positionY <= positionY + 20; --dol
	elsif (direction = "00") then
		 positionY <= positionY - 20; --gora
	end if;
end procedure make_move;

procedure make_move_batch (
	signal tail_directions : STD_LOGIC_VECTOR(19 downto 0);
	signal tail_positions_x : inout tail_x;
	signal tail_positions_y : inout tail_y;
	tailIndex : in natural
) is 
variable currentDirection : STD_LOGIC_VECTOR(1 downto 0);
begin
	for i in 9 downto 0 loop --tailIndex

		if( i >= tailIndex ) then
			next;
		end if;
		
		currentDirection := tail_directions(i*2+1 downto i*2);
		if (currentDirection = "01") then
			 tail_positions_x(i) <= tail_positions_x(i) + 20; --prawo
		elsif (currentDirection = "11") then
			 tail_positions_x(i) <= tail_positions_x(i) - 20; --lewo
		elsif (currentDirection = "10") then
			 tail_positions_y(i) <= tail_positions_y(i) + 20; --dol
		elsif (currentDirection = "00") then
			 tail_positions_y(i) <= tail_positions_y(i) - 20; --gora
		end if;
	
	end loop;
	
end procedure make_move_batch;

--for single head with single tail
function check_collision_with_tail (
	signal positionX : STD_LOGIC_VECTOR(10 downto 0);
	signal positionY : STD_LOGIC_VECTOR(8 downto 0);
	signal tail_positions_x : in tail_x;
	signal tail_positions_y : in tail_y;
	tailIndex : in natural
) return std_logic is 
variable result : std_logic := '0';
begin
	for i in 9 downto 0 loop --tailIndex

		if( i >= tailIndex ) then
			next;
		end if;
		
		if( positionX = tail_positions_x(i) and positionY = tail_positions_y(i) ) then
			result := '1';
			exit;
		end if;
	
	end loop;
	
	return result;
end function check_collision_with_tail;

procedure determine_direction (
	signal last_direction : inout STD_LOGIC_VECTOR(1 downto 0);
	signal znak_klw : in STD_LOGIC_VECTOR(7 downto 0)
) is 
variable currentDirection : STD_LOGIC_VECTOR(1 downto 0);
begin
	if( znak_klw /= "00000000" ) then
		if (znak_klw = X"23") then
			 currentDirection := "01"; 
		elsif (znak_klw = X"1C") then
			 currentDirection := "11";
		elsif (znak_klw = X"1B") then
			 currentDirection := "10"; 
		elsif (znak_klw = X"1D") then
			 currentDirection := "00";
		end if;
		
		--zabraniamy chodzenia w kierunku przeciwnym  niz obecny
		if( (last_direction = "00" and currentDirection /= "10") or 
			(last_direction = "01" and currentDirection /= "11") or
			(last_direction = "10" and currentDirection /= "00") or
			(last_direction = "11" and currentDirection /= "01") ) then
				last_direction <= currentDirection;
		end if;
	end if;
end procedure determine_direction;

procedure move_snake (
	signal last_direction : inout STD_LOGIC_VECTOR(1 downto 0);
	signal positionX : inout STD_LOGIC_VECTOR(10 downto 0);
	signal positionY : inout STD_LOGIC_VECTOR(8 downto 0);
	signal tail_positions_x : inout tail_x;
	signal tail_positions_y : inout tail_y;
	signal tail_directions : inout STD_LOGIC_VECTOR(19 downto 0);
	tailIndex : in natural
) is 
variable currentDirection : STD_LOGIC_VECTOR(1 downto 0);
begin
	--moving head
	make_move( last_direction, positionX, positionY );

	--moving tail for snake 1
	make_move_batch( tail_directions, tail_positions_x, tail_positions_y, tailIndex);
	
	tail_directions <= tail_directions(17 downto 0) & last_direction; --rejestr przesuwny  
end procedure move_snake;

-- LOGIKA GRY -----------------
-- polozenie glow 
signal snake_1_x, snake_2_x, apple_x : STD_LOGIC_VECTOR(10 downto 0); 
signal snake_1_y, snake_2_y, apple_y : STD_LOGIC_VECTOR(8 downto 0);
-- jest jabuszko na planszy?
signal isAppleOnBoard : STD_LOGIC := '0'; -- czy jest jablko na planszy
-- reset gry?
signal end_game : std_logic_vector(1 downto 0) := "00"; -- oznajmia koniec rozrywki (0. bit) oraz kto wygra³ (1. bit - '0' gracz 1, a '1' gracz 2) 
-- END LOGIKA GRY ---------------

-- KLAWISZE--------------------
signal znak_klw1, znak_klw2: std_logic_VECTOR(7 downto 0);
signal last_direction_1, last_direction_2 : std_logic_VECTOR(1 downto 0);
-- END KLAWISZE ----------------------------

-- RANDOM
signal random_num : STD_LOGIC_VECTOR(10 downto 0) := (10 => '1', others => '0');
signal random_num2 : STD_LOGIC_VECTOR(10 downto 0) := (10 => '1', others => '0');
-- END RANDOM

-- TIMING
signal sekunda : STD_LOGIC_VECTOR(24 downto 0);
signal round_duration : STD_LOGIC_VECTOR(24 downto 0) := "0111111111111111111111111";
-- END OF TIMING

-- TAIL 
signal tail_x_1 : tail_x;
signal tail_y_1 : tail_y;
signal tail_x_2 : tail_x;
signal tail_y_2 : tail_y;
signal tail_length_1 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal tail_directions_1 : STD_LOGIC_VECTOR(19 downto 0);
signal tail_length_2 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal tail_directions_2 : STD_LOGIC_VECTOR(19 downto 0);
-- END OF TAIL
begin

DZIALANIE : process (clk_50MHz, RESET)
variable divResult : natural := 0;
variable tailIndex_1, tailIndex_2 : natural;
begin
	 if RESET = '0' or end_game /= "00" then
		-- 5x5
		snake_1_x <= "00001011010";
		snake_1_y <= "001011010";
		-- 10x10
		snake_2_x <= "00010111110";
		snake_2_y <= "010111110";
		-- apple
		-- 0x0
		apple_x <= "00000001010";
		apple_y <= "000001010";
		-- game is on!
		end_game <= "00";
		isAppleOnBoard <= '0';
		
		last_direction_1 <= "10"; --dol
		last_direction_2 <= "10"; --dol
		tail_directions_1 <= (others => '0');
		tail_directions_2 <= (others => '0');
		-- reseting tail
		tail_length_1 <= (others => '0');
		tail_length_2 <= (others => '0');
		for i in 7 downto 0 loop
			tail_x_1(i) <= (others => '0');
			tail_y_1(i) <= (others => '0');
			tail_x_2(i) <= (others => '0');
			tail_y_2(i) <= (others => '0');
		end loop;
	 elsif (rising_edge(clk_50MHz)) then -- rozrywka trwa
         sekunda <= sekunda + 1;	
			
			determine_direction( last_direction_1, znak_klw1 );
			determine_direction( last_direction_2, znak_klw2 );
			
         ----------------------------------------			
			if (sekunda = round_duration and end_game = "00") then -- 1.5Hz
				sekunda <= (others => '0'); -- reseting clock
				
				tailIndex_1 := conv_integer(tail_length_1);
				move_snake( last_direction_1, snake_1_x, snake_1_y, tail_x_1, tail_y_1, tail_directions_1, tailIndex_1 );
				
				tailIndex_2:= conv_integer(tail_length_2);
				move_snake( last_direction_2, snake_2_x, snake_2_y, tail_x_2, tail_y_2, tail_directions_2, tailIndex_2 );

				--checking for game over
				if snake_1_x = snake_2_x and snake_1_y = snake_2_y then
					end_game <= "11"; --remis
				end if;
				
				--granice planszy
				if snake_1_x < 0 or snake_1_x > 1281 or snake_1_y < 0 or snake_1_y > 400 then
					end_game <= "01";
				elsif snake_2_x < 0 or snake_2_x > 1281 or snake_2_y < 0 or snake_2_y > 400 then
					end_game <= "10";
				end if;
				
				-- zderzenia z ogonami
				if( (check_collision_with_tail( snake_1_x, snake_1_y, tail_x_1, tail_y_1, tailIndex_1) = '1')
					or (check_collision_with_tail( snake_1_x, snake_1_y, tail_x_2, tail_y_2, tailIndex_2) = '1') ) then
					-- second won
					end_game <= "01";
				elsif( (check_collision_with_tail( snake_2_x, snake_2_y, tail_x_1, tail_y_1, tailIndex_1) = '1')
					or (check_collision_with_tail( snake_2_x, snake_2_y, tail_x_2, tail_y_2, tailIndex_2) = '1') ) then
					-- first won
					end_game <= "10";
				end if;
				
				
				--jabuszko
				if( snake_1_x = apple_X and snake_1_y = apple_Y and isAppleOnBoard = '1' ) then
					isAppleOnBoard <= '0';
					round_duration <= round_duration - 1000000;
					tail_length_1 <= tail_length_1 + 1;
					--adding new element of tail
					if( tailIndex_1 = 0 ) then
						tail_x_1(0) <= snake_1_x;
						tail_y_1(0) <= snake_1_y;
					else 
						tail_x_1(tailIndex_1) <= tail_x_1(tailIndex_1-1);
						tail_y_1(tailIndex_1) <= tail_y_1(tailIndex_1-1);
					end if;
				elsif( snake_2_x = apple_X and snake_2_y = apple_Y and isAppleOnBoard = '1' ) then
					isAppleOnBoard <= '0';
					round_duration <= round_duration - 1000000;
					tail_length_2 <= tail_length_2 + 1;
					--adding new element of tail
					if( tailIndex_1 = 0 ) then
						tail_x_2(0) <= snake_2_x;
						tail_y_2(0) <= snake_2_y;
					else 
						tail_x_2(tailIndex_2) <= tail_x_2(tailIndex_2-1);
						tail_y_2(tailIndex_2) <= tail_y_2(tailIndex_2-1);
					end if;
				end if;
			else 
				--jak nie ma jabuszka to losujemy na bazie obecnej sekundy
				if isAppleOnBoard = '0' then
					--losujemy jablko
					-- x
					divResult := conv_integer(random_num(5 downto 0))*20 - 10;
					apple_X <= conv_std_logic_vector(divResult, 11);
					
					-- y
					divResult := conv_integer(random_num(9 downto 6))*20 - 10;
					apple_Y <= conv_std_logic_vector(divResult, 9);
					
					if( apple_Y > 400 or apple_Y < 30 or apple_X < 10 or apple_X > 1250 ) then
						isAppleOnBoard <= '0';
					else 
						isAppleOnBoard <= '1';
					end if;
				end if;
			end if;
	 end if;
end process; 
  

-------------------------------------------------------------------------------- 
klaw: klawiatura port map(clk_50MHz =>clk_50MHz, RESET =>RESET, keyb_clk =>keyb_clk, keyb_data=>keyb_data, znak_klw=> znak_klw1);
		
klaw2: klawiatura port map(clk_50MHz =>clk_50MHz, RESET =>RESET, keyb_clk =>keyb_clk2, keyb_data=>keyb_data2, znak_klw=> znak_klw2);		
		
ekran: monitor port map(
	---podstawowe sygnaly
	clk_50MHz =>clk_50MHz, RESET =>RESET, hsync =>hsync, vsync =>vsync, kolor =>kolor,
	--dodatkowe (logika gry)
	snake_1_x => snake_1_x,
	snake_1_y => snake_1_y,
	snake_2_x => snake_2_x,
	snake_2_y => snake_2_y,
	apple_x => apple_x,
	apple_y => apple_y,
	tail_1_x => tail_x_1,
	tail_1_y => tail_y_1,
	tail_2_x => tail_x_2,
	tail_2_y => tail_y_2
	);

 random_generator: entity random
		PORT MAP (
          clk => clk_50MHz,
          random_num => random_num
        );
  
  random_generator2: entity random
		PORT MAP (
          clk => clk_50MHz,
          random_num => random_num2
        );

end vga_arch;



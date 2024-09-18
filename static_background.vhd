----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2024 08:16:57 PM
-- Design Name: 
-- Module Name: static_background - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity static_background is
Port (hcount,vcount : in STD_LOGIC_VECTOR(10 downto 0); blank : in STD_LOGIC;
      Red,Green,Blue : out STD_LOGIC_VECTOR(3 downto 0));
end static_background;

architecture Behavioral of static_background is
begin
 process(hcount,vcount,blank)
 begin
  if((hcount >= 0 and hcount <= 639 and blank = '0') and    -- Upper/Lower Horizontal border
     ((vcount >= 0 and vcount <= 20) or (vcount >= 459 and vcount <= 479))) then
     Green <= X"0";		-- Blue + Red makes MAGENTA 
  	 Blue <= X"F";
  	 Red <= X"F";
  elsif((vcount >= 21 and vcount <= 458 and blank = '0') and    -- Left/Right Vertical border
        ((hcount >= 0 and hcount <= 25) or (hcount >= 620 and hcount <= 639))) then 
     Green <= X"0";		-- Blue + Red makes MAGENTA 
     Blue <= X"F";
     Red <= X"F";
  else
     Green <= X"0";
     Blue <= X"0";
     Red <= X"0";
  end if;
 end process;

end Behavioral;
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/10/2024 08:01:08 PM
-- Design Name: 
-- Module Name: alu - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

entity alu is
port(A, B : in SIGNED(7 downto 0);
        F : in STD_LOGIC_VECTOR(2 downto 0);
        Y : out SIGNED(7 downto 0);
    N,V,Z : out STD_LOGIC);
end alu;

architecture a of alu is
-- ------- Function to determine if overflow occurs ---------
function ISOVERFLOW(constant A, B, R : SIGNED(7 downto 0)) return STD_LOGIC is
variable RETVAL : STD_LOGIC;
begin
  if(((A(7) and B(7) and not R(7)) OR (not A(7) and not B(7) and R(7))) = '1') then
       RETVAL := '1';
  else
       RETVAL := '0';
  end if;
 return RETVAL;
end function;
-- ----------------------------------------------------------
begin
-- ---------- Update Condition Code flag bits ---------------
process (A,B,F)
variable RETVAL : SIGNED(7 downto 0);
begin
  V <= '0';
  if(F = "000") then                        -- Addition
     RETVAL := A + B;
     V <= ISOVERFLOW(A,B,RETVAL);           -- OVERFLOW flag
  elsif(F = "001") then                     -- Subtraction
     RETVAL := A - B;
     V <= ISOVERFLOW(A,-B,RETVAL);
  elsif(F = "010") then                             -- LSL
     RETVAL := A(6 downto 0) & '0';
  elsif(F = "011") then                             -- LSR
     RETVAL := '0' & A(7 downto 1);
  elsif(F = "100") then                             -- XOR
     RETVAL := SIGNED(STD_LOGIC_VECTOR(A) xor STD_LOGIC_VECTOR(B));
  elsif(F = "101") then                             -- COM
     RETVAL := SIGNED(not STD_LOGIC_VECTOR(A));
  elsif(F = "110") then                             -- NEG
     RETVAL := 0 - A;
     if(STD_LOGIC_VECTOR(RETVAL) = "10000000") then
        V <= '1';
     end if;
  else                                              -- CLR
     RETVAL := "00000000";
  end if;
        
  if(STD_LOGIC_VECTOR(RETVAL) = "00000000") then    -- ZERO flag
     Z <= '1';
  else
     Z <= '0';
  end if;
        
  if(RETVAL(7) = '1') then                          -- NEG flag
     N <= '1';
  else
     N <= '0';
  end if;

  Y <= RETVAL;
end process;

end architecture a;


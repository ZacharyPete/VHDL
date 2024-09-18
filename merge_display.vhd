----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2024 08:23:20 PM
-- Design Name: 
-- Module Name: merge_display - Behavioral
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

entity merge_display is
Port (Red_a,Red_b,Red_c,Red_d,Red_e : in STD_LOGIC_VECTOR(3 downto 0);
      Green_a,Green_b,Green_c,Green_d,Green_e : in STD_LOGIC_VECTOR(3 downto 0);
      Blue_a,Blue_b,Blue_c,Blue_d,Blue_e : in STD_LOGIC_VECTOR(3 downto 0);
      R3,R2,R1,R0,G3,G2,G1,G0,B3,B2,B1,B0 : out STD_LOGIC);
end merge_display;

architecture Behavioral of merge_display is
begin
 R3 <= Red_a(3) or Red_b(3) or Red_c(3) or Red_d(3) or Red_e(3);
 R2 <= Red_a(2) or Red_b(2) or Red_c(2) or Red_d(2) or Red_e(2);
 R1 <= Red_a(1) or Red_b(1) or Red_c(1) or Red_d(1) or Red_e(1);
 R0 <= Red_a(0) or Red_b(0) or Red_c(0) or Red_d(0) or Red_e(0);
 
 G3 <= Green_a(3) or Green_b(3) or Green_c(3) or Green_d(3) or Green_e(3);
 G2 <= Green_a(2) or Green_b(2) or Green_c(2) or Green_d(2) or Green_e(2);
 G1 <= Green_a(1) or Green_b(1) or Green_c(1) or Green_d(1) or Green_e(1);
 G0 <= Green_a(0) or Green_b(0) or Green_c(0) or Green_d(0) or Green_e(0);
 
 B3 <= Blue_a(3) or Blue_b(3) or Blue_c(3) or Blue_d(3) or Blue_e(3);
 B2 <= Blue_a(2) or Blue_b(2) or Blue_c(2) or Blue_d(2) or Blue_e(2);
 B1 <= Blue_a(1) or Blue_b(1) or Blue_c(1) or Blue_d(1) or Blue_e(1);
 B0 <= Blue_a(0) or Blue_b(0) or Blue_c(0) or Blue_d(0) or Blue_e(0);

end Behavioral;

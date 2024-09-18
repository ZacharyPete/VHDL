library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TwoBitCounter is
    Port (
        clk : in STD_LOGIC;              -- Clock input
        reset : in STD_LOGIC;            -- Reset input
        count : out STD_LOGIC_VECTOR(1 downto 0)  -- 2-bit counter output
    );
end TwoBitCounter;

architecture Behavioral of TwoBitCounter is
    signal internal_count : STD_LOGIC_VECTOR(1 downto 0) := "00";
begin
    -- Counter process
    counter_process : process(clk, reset)
    begin
        if reset = '1' then
            internal_count <= "00";
        elsif rising_edge(clk) then
            internal_count <= internal_count + 1;
        end if;
    end process counter_process;

    -- Output assignment
    count <= internal_count;

end Behavioral;

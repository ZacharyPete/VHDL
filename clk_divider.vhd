library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClockDivider is
    Port (
        clk_in : in STD_LOGIC;  -- Input clock
        reset : in STD_LOGIC;   -- Reset signal
        clk_out : out STD_LOGIC -- Output clock
    );
end ClockDivider;

architecture Behavioral of ClockDivider is
    constant COUNTER_WIDTH : integer := 10;
    constant DIVIDE_BY : integer := 1024; -- Change this to your desired division factor
    signal counter : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal toggle : STD_LOGIC := '0';  -- Intermediate toggle signal
begin
    process(clk_in, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            toggle <= '0';
        elsif rising_edge(clk_in) then
            if counter = DIVIDE_BY - 1 then
                counter <= (others => '0');
                toggle <= not toggle; -- Update the intermediate toggle signal
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    clk_out <= toggle; -- Assign the toggled state to clk_out outside the if-elsif block
end Behavioral;

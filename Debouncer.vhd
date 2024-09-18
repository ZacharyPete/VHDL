library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Debouncer is
    Port (
        btn_in : in STD_LOGIC;
        clk    : in STD_LOGIC;
        reset  : in STD_LOGIC;
        btn_out: out STD_LOGIC
    );
end Debouncer;

architecture Behavioral of Debouncer is
    signal delay1, delay2, delay3: STD_LOGIC;
begin

    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset each signal individually
            delay1 <= '0';
            delay2 <= '0';
            delay3 <= '0';
        elsif rising_edge(clk) then
            -- Shift registers to create delay
            delay1 <= btn_in;
            delay2 <= delay1;
            delay3 <= delay2;
        end if;
    end process;

    -- Logical AND to ensure button is stable over three clock cycles
    btn_out <= delay1 and delay2 and delay3;

end Behavioral;

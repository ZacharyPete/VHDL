library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux2to1 is
    Port (
        data0 : in STD_LOGIC_VECTOR(1 downto 0);  -- Input data line 0
        data1 : in STD_LOGIC_VECTOR(1 downto 0);  -- Input data line 1
        selecter : in STD_LOGIC;                    -- Select signal
        out_data : out STD_LOGIC_VECTOR(1 downto 0)  -- Output data line
    );
end Mux2to1;

architecture Behavioral of Mux2to1 is
begin
    -- Multiplexer process
    mux_process : process(data0, data1, selecter)
    begin
        if selecter = '0' then
            out_data <= data0;
        else
            out_data <= data1;
        end if;
    end process mux_process;
    
end Behavioral;

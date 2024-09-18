library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Keypad_Controller is
    Port (
        Clk        : in STD_LOGIC;  -- System Clock signal at 25 MHz
        Row        : in STD_LOGIC_VECTOR(3 downto 0);  -- Keypad row inputs
        Col        : out STD_LOGIC_VECTOR(3 downto 0);  -- Keypad column outputs
        BtnUp      : out STD_LOGIC;  -- Button Up
        BtnDown    : out STD_LOGIC;  -- Button Down
        BtnLeft    : out STD_LOGIC;  -- Button Left
        BtnRight   : out STD_LOGIC   -- Button Right
    );
end Keypad_Controller;

architecture Behavioral of Keypad_Controller is
    -- Clock division for scanning frequency 
    signal scan_clk : STD_LOGIC := '0';
    signal scan_counter : integer := 0;
    constant scan_period : integer := 25000; 

    -- Debouncing
    signal debounced_Row : STD_LOGIC_VECTOR(3 downto 0) := "1111";
    signal debounce_counter : integer := 0;
    constant debounce_limit : integer := 2500; -- Adjust based on your clock frequency for debounce timing

    -- Current column being scanned
    signal current_col : integer range 0 to 3 := 0;
begin
    -- Clock divider process
    process(Clk)
    begin
        if rising_edge(Clk) then
            if scan_counter < scan_period - 1 then
                scan_counter <= scan_counter + 1;
            else
                scan_counter <= 0;
                scan_clk <= not scan_clk; -- Toggle scan clock
            end if;
        end if;
    end process;

    -- Keypad scanning and debouncing process
    process(scan_clk)
    begin
        if rising_edge(scan_clk) then
            -- Debouncing logic
            if Row /= debounced_Row and debounce_counter < debounce_limit then
                debounce_counter <= debounce_counter + 1;
            elsif debounce_counter >= debounce_limit then
                debounce_counter <= 0;
                debounced_Row <= Row; -- Update debounced row value
            end if;

            -- Scanning logic
            case current_col is
                when 0 =>
                    Col <= "1110"; -- Activate first column
                when 1 =>
                    Col <= "1101"; -- Activate second column
                when 2 =>
                    Col <= "1011"; -- Activate third column
                when 3 =>
                    Col <= "0111"; -- Activate fourth column
                when others =>
                    Col <= "1111"; -- Deactivate all columns
            end case;
            current_col <= (current_col + 1) mod 4; -- Move to next column
            
            -- Set button signals based on debounced input
            BtnUp <= '0';
            BtnDown <= '0';
            BtnLeft <= '0';
            BtnRight <= '0';
            if debounced_Row(1) = '0' then
                case current_col is
                    when 0 => BtnUp <= '1';
                    when 2 => BtnDown <= '1';
                    when others => null;
                end case;
            elsif debounced_Row(0) = '0' then
                BtnLeft <= '1';
            elsif debounced_Row(2) = '0' then
                BtnRight <= '1';
            end if;
        end if;
    end process;
end Behavioral;

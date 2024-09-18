library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- SlotMachine entity declaration with two sets of anodes and cathodes for reels and WIN/SPIN display
entity SlotMachine is
    Port (
        clk : in STD_LOGIC;                           -- Clock input
        reset : in STD_LOGIC;                         -- Reset input
        btn_spin : in STD_LOGIC;                      -- Button to start spinning the reels
        btn_stop : in STD_LOGIC;                      -- Button to stop the reels
        btn_reset : in STD_LOGIC;                     -- Button to reset the reels
        anodes_reels : out STD_LOGIC_VECTOR(3 downto 0);     -- Anode signals for the reel displays
        cathodes_reels : out STD_LOGIC_VECTOR(7 downto 0);   -- Cathode signals for the reel segments
        anodes_win_spin : out STD_LOGIC_VECTOR(3 downto 0);  -- Anode signals for the WIN/SPIN display
        cathodes_win_spin : out STD_LOGIC_VECTOR(7 downto 0) -- Cathode signals for the WIN/SPIN segments
    );
end SlotMachine;

architecture Behavioral of SlotMachine is
    -- Define the state machine states
    type T_State is (IDLE, SPINNING, STOPPED, DISPLAY_WIN, DISPLAY_SPIN);
    signal state : T_State := IDLE;

    -- Define an array type for managing the reel values
    subtype reel_value_type is unsigned(3 downto 0);
    type reel_values_array is array (natural range <>) of reel_value_type;
    
    -- Define a constant for the number of reels
    constant NUM_REELS : natural := 3;  -- Example for three reels
    
    -- Define signals for managing the reel values and spin rates
    signal reel_values : reel_values_array(1 to NUM_REELS) := (others => (others => '0'));
    signal spin_rate : integer range 1 to 9 := 3;    -- Rate at which the reels spin

    -- Define signals for controlling the 7-segment display
    signal win_spin_value : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');  -- Holds the segments to display WIN or SPIN

    -- Spin counters to control the rate of increment for each reel
    signal spin_counters : reel_values_array(1 to NUM_REELS) := (others => (others => '0'));

begin
    -- State machine process
    sm_process : process(clk, reset)
    begin
        if reset = '1' then
            -- Reset the state machine and all counters
            state <= IDLE;
            reel_values <= (others => (others => '0'));
            win_spin_value <= (others => '0');
            -- Reset spin counters
            spin_counters <= (others => (others => '0'));
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    -- Wait for the user to press the spin button
                    if btn_spin = '1' then
                        state <= SPINNING;
                    end if;
                    
                when SPINNING =>
                    -- Spin the reels and wait for the user to press the stop button
                    if btn_stop = '1' then
                        state <= STOPPED;
                    end if;
                    
                when STOPPED =>
                    -- Determine the outcome and show WIN or SPIN
                    -- Placeholder for win condition check
                    state <= DISPLAY_SPIN;  -- Default to SPIN for now
                    
                when DISPLAY_WIN =>
                    -- Display WIN and wait for reset
                    if btn_reset = '1' then
                        state <= IDLE;
                    end if;
                    
                when DISPLAY_SPIN =>
                    -- Display SPIN and wait for reset
                    if btn_reset = '1' then
                        state <= IDLE;
                    end if;
                    
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process sm_process;

    -- Reel spinning process
    -- This process increments the reel values based on the spin counters
 reel_spinning_process : process(clk)
    -- Declare a constant for the length of the counters
    constant COUNTER_LENGTH : natural := reel_values'length;
begin
    if rising_edge(clk) and state = SPINNING then
        -- Check spin counter for each reel and increment or reset accordingly
        for i in reel_values'range loop
            -- Increment the spin counter
            spin_counters(i) <= spin_counters(i) + 1;

            -- Check if the spin counter meets the spin rate for the current reel
            -- Assuming spin_rate is an integer, it is multiplied by i (also an integer) directly
            if spin_counters(i) >= to_unsigned(spin_rate * i, COUNTER_LENGTH) then
                -- Increment the reel value
                reel_values(i) <= reel_values(i) + 1;

                -- Reset the counter for this reel
                spin_counters(i) <= (others => '0');

                -- Check if the reel value has rolled over (i.e., exceeded 9)
                if reel_values(i) >= to_unsigned(10, COUNTER_LENGTH) then
                    -- Reset the reel value
                    reel_values(i) <= (others => '0');
                end if;
            end if;
        end loop;
    end if;
end process reel_spinning_process;



    -- Display update process
    -- This process handles the display updates based on the current state and reel values
    display_update_process : process(clk)
    begin
        if rising_edge(clk) then
            -- Update display based on the current state
            case state is
                when DISPLAY_WIN =>
                    -- Set display value for WIN
                    win_spin_value <= "01100010"; -- Binary representation for 'W'
                when DISPLAY_SPIN =>
                    -- Set display value for SPIN
                    win_spin_value <= "10010010"; -- Binary representation for 'S'
                when others =>
                    -- Clear display value when not in DISPLAY_WIN or DISPLAY_SPIN
                    win_spin_value <= (others => '0');
            end case;
        end if;
    end process display_update_process;

    -- Output assignment
    -- This section drives the actual anodes and cathodes based on the values set in the display update process
    anodes_reels <= (others => '1');  -- Anodes are active low, so '1' turns them off by default
    cathodes_reels <= (others => '1');  -- Cathodes are active low, so '1' turns them off by default
    anodes_win_spin <= (others => '1'); -- Anodes are active low, so '1' turns them off by default
    cathodes_win_spin <= win_spin_value;  -- Display the win or spin value on the 7-segment display

end Behavioral;

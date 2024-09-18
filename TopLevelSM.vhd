library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopLevel is
    Port (
        clk : in STD_LOGIC;                            
        reset : in STD_LOGIC;                          
        btn1_raw : in STD_LOGIC;                       
        btn3_raw : in STD_LOGIC;                       
        reel_count_display : out STD_LOGIC_VECTOR(7 downto 0); 
        seven_seg_display : out STD_LOGIC_VECTOR(7 downto 0); 
        Anode_reels: out STD_LOGIC_VECTOR(3 downto 0); 
        Anode_win: out STD_LOGIC_VECTOR(3 downto 0)
    );
end TopLevel;

architecture Behavioral of TopLevel is
    -- Internal signals
    -- Signal declarations that will be connected to the SlotMachine ports
    signal clk_divided : STD_LOGIC;
    signal btn1_debounced : STD_LOGIC;
    signal btn3_debounced : STD_LOGIC;
    signal anodes_reels : STD_LOGIC_VECTOR(3 downto 0);
    signal cathodes_reels : STD_LOGIC_VECTOR(7 downto 0);
    signal anodes_win_spin : STD_LOGIC_VECTOR(3 downto 0);
    signal cathodes_win_spin : STD_LOGIC_VECTOR(7 downto 0);
    signal btn_reset_debounced : STD_LOGIC; -- Assuming you have a debounced reset button signal

begin
    -- Clock Divider Instantiation (Assuming existing entity)
    clk_divider_inst : entity work.ClockDivider
    port map (
        clk_in => clk,
        reset => reset,
        clk_out => clk_divided
    );

    -- Button Debouncers Instantiation (Assuming existing entity)
    btn1_debouncer_inst : entity work.Debouncer
    port map (
        clk => clk_divided,
        reset => reset,
        btn_in => btn1_raw,
        btn_out => btn1_debounced
    );

    btn3_debouncer_inst : entity work.Debouncer
    port map (
        clk => clk_divided,
        reset => reset,
        btn_in => btn3_raw,
        btn_out => btn3_debounced
    );

    -- Slot Machine Instantiation
   slot_machine_inst : entity work.SlotMachine
    port map (
        clk             => clk,                  -- Connect to main clock signal
        reset           => reset,                -- Connect to reset signal
        btn_spin        => btn1_raw,             -- Connect to raw spin button signal
        btn_stop        => btn3_raw,             -- Connect to raw stop button signal
        btn_reset       => btn3_raw,             -- Assuming the reset button is the same as the stop button for simplicity
        anodes_reels    => anodes_reels,         -- Connect to anodes for the reel displays
        cathodes_reels  => cathodes_reels,       -- Connect to cathodes for the reel segments
        anodes_win_spin => anodes_win_spin,      -- Connect to anodes for the WIN/SPIN display
        cathodes_win_spin => cathodes_win_spin   -- Connect to cathodes for the WIN/SPIN segments
    );
    -- Additional logic to map SlotMachine outputs to TopLevel outputs might be needed here
    -- This part is conceptual, as direct mapping from anodes/cathodes to a 7-segment display output
    -- and reel count display is not straightforward without additional details on the display handling logic.

end Behavioral;

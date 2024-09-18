library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity segment_module is
    Port (
        clk_100MHz : in STD_LOGIC;
         x1 : in STD_LOGIC_VECTOR(3 downto 0);
         x2 : in STD_LOGIC_VECTOR(3 downto 0) ;
         y1 : in STD_LOGIC_VECTOR(3 downto 0);
         y2 : in STD_LOGIC_VECTOR(3 downto 0) ;
        reset : in STD_LOGIC;
        reel_count_display, seven_seg_display : out STD_LOGIC_VECTOR(6 downto 0);  -- segment pattern 0-9
                            -- decimal point
        Anode_reels, Anode_win : out STD_LOGIC_VECTOR(3 downto 0) -- digit select signals
    );
end segment_module;

architecture Behavioral of segment_module is
signal dp :  STD_LOGIC := '1'; 

      
component seg_display_driver is
    Port (
        clk_100MHz : in STD_LOGIC;
        reset : in STD_LOGIC;
        x1 : in STD_LOGIC_VECTOR(3 downto 0);
        x2 : in STD_LOGIC_VECTOR(3 downto 0);
        y1 : in STD_LOGIC_VECTOR(3 downto 0);
        y2 : in STD_LOGIC_VECTOR(3 downto 0);
        seg : out STD_LOGIC_VECTOR(6 downto 0);  -- segment pattern 0-9
        dp : out STD_LOGIC;                     -- decimal point
        digit : out STD_LOGIC_VECTOR(3 downto 0) -- digit select signals
    );
end component;


begin

segment_display_left: seg_display_driver port map(
clk_100MHz => clk_100MHz,
reset => reset,
x1 => x1,
x2 => x2,
y1 => x"F",
y2 => x"F",
seg => reel_count_display,
dp => dp,
digit => Anode_reels
);

segment_display_right: seg_display_driver port map(
clk_100MHz => clk_100MHz,
reset => reset,
x1 => y1,
x2 => y2,
y1 => x"F",
y2 => x"F",
seg => seven_seg_display,
dp => dp,
digit => Anode_win
);
end Behavioral;
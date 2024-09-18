library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Required for to_unsigned, to_integer, and numeric operations

entity title_block is
    Port (
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        blank       : in STD_LOGIC;
        hcount      : in STD_LOGIC_VECTOR(10 downto 0);
        vcount      : in STD_LOGIC_VECTOR(10 downto 0);
        RedCubeX    : in STD_LOGIC_VECTOR(10 downto 0);
        RedCubeY    : in STD_LOGIC_VECTOR(10 downto 0);
        GreenCubeX  : in STD_LOGIC_VECTOR(10 downto 0);
        GreenCubeY  : in STD_LOGIC_VECTOR(10 downto 0);
        RedStopped  : in STD_LOGIC;
        Red         : out STD_LOGIC_VECTOR(3 downto 0);
        Green       : out STD_LOGIC_VECTOR(3 downto 0);
        Blue        : out STD_LOGIC_VECTOR(3 downto 0)
    );
end title_block;

architecture Behavioral of title_block is
    signal distanceSquared : integer;
    signal squareDisplayed : boolean := false;
    signal squareColor : std_logic_vector(2 downto 0); -- RGB

begin
    process(RedCubeX, RedCubeY, GreenCubeX, GreenCubeY)
    begin
        distanceSquared <= (to_integer(unsigned(GreenCubeX)) - to_integer(unsigned(RedCubeX)))**2 +
                           (to_integer(unsigned(GreenCubeY)) - to_integer(unsigned(RedCubeY)))**2;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                squareDisplayed <= false; -- Reset the display flag on reset
            elsif RedStopped = '1' and not squareDisplayed then
                -- Decide the color based on distance when RedStopped is set and square not yet displayed
                if distanceSquared <= (80*80) then
                    squareColor <= "010"; -- Green
                else
                    squareColor <= "100"; -- Red
                end if;
                squareDisplayed <= true; -- Mark square as displayed
            end if;
            
            if blank = '0' and squareDisplayed and
               to_integer(unsigned(hcount)) >= 100 and to_integer(unsigned(hcount)) < 120 and
               to_integer(unsigned(vcount)) >= 100 and to_integer(unsigned(vcount)) < 120 then
                -- Apply the decided color to the square
                Red   <= squareColor(2) & "111";
                Green <= squareColor(1) & "111";
                Blue  <= squareColor(0) & "000";
            else
                -- Blank the output when outside the square area
                Red   <= (others => '0');
                Green <= (others => '0');
                Blue  <= (others => '0');
            end if;
        end if;
    end process;
end Behavioral;

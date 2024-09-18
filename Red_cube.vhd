library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- This library is required for to_unsigned, to_integer and numeric operations

entity Yellow_Circle is
    Port (
        reset       : in  STD_LOGIC;
        vs          : in  STD_LOGIC;
        blank       : in  STD_LOGIC;
        hcount      : in  STD_LOGIC_VECTOR(10 downto 0);
        vcount      : in  STD_LOGIC_VECTOR(10 downto 0);
        xpos        : out STD_LOGIC_VECTOR(10 downto 0);  -- X position output
        ypos        : out STD_LOGIC_VECTOR(10 downto 0);
        Red         : out STD_LOGIC_VECTOR(3 downto 0);
        Green       : out STD_LOGIC_VECTOR(3 downto 0);
        Blue        : out STD_LOGIC_VECTOR(3 downto 0);
        check_flag  : out STD_LOGIC  -- Output signal indicating movement sequence completion
    );
end Yellow_Circle;

architecture Behavioral of Yellow_Circle is
    constant Circle_Radius : integer := 80;
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;
    -- Constants from Green_cube for consistent starting positions
    constant WIDTH : integer := 62;  -- Width of the object
    constant HEIGHT : integer := 65;  -- Height of the object
    -- Calculating the center position considering the object's dimensions
    constant START_X_POS : integer := (SCREEN_WIDTH / 2) - (WIDTH / 2);
    constant START_Y_POS : integer := (SCREEN_HEIGHT / 2) - (HEIGHT / 2);

    -- Using calculated positions for initial position
    signal Object_X_pos : STD_LOGIC_VECTOR(10 downto 0) := std_logic_vector(to_unsigned(START_X_POS, 11));
    signal Object_Y_pos : STD_LOGIC_VECTOR(10 downto 0) := std_logic_vector(to_unsigned(START_Y_POS, 11));
    signal move_phase : integer := 0;
    signal move_counter : integer := 0;
    signal internal_check_flag : STD_LOGIC := '0'; -- Internal signal to manage movement completion
   
begin

    -- Movement control process
    process(vs, reset)
    begin
        if reset = '1' then
            Object_X_pos <= std_logic_vector(to_unsigned(SCREEN_WIDTH / 2, 11));
            Object_Y_pos <= std_logic_vector(to_unsigned(SCREEN_HEIGHT / 2, 11));
            move_phase <= 0;
            move_counter <= 0;
            internal_check_flag <= '0'; -- Reset internal check flag
        elsif rising_edge(vs) then
            case move_phase is
                when 0 to 2 => -- Move right three times
                    if move_counter < 60 then -- Move for 60 steps
                        Object_X_pos <= std_logic_vector(unsigned(Object_X_pos) + 1);
                        move_counter <= move_counter + 1;
                    else
                        move_phase <= move_phase + 1; -- Proceed to next phase
                        move_counter <= 0;
                    end if;
                when 3 to 4 => -- Move down twice
                    if move_counter < 40 then -- Move for 40 steps
                        Object_Y_pos <= std_logic_vector(unsigned(Object_Y_pos) + 1);
                        move_counter <= move_counter + 1;
                    else
                        move_phase <= move_phase + 1;
                        move_counter <= 0;
                    end if;
                when 5 to 6 => -- Move left twice
                    if move_counter < 60 then -- Move for 60 steps
                        Object_X_pos <= std_logic_vector(unsigned(Object_X_pos) - 1);
                        move_counter <= move_counter + 1;
                    else
                        move_phase <= move_phase + 1;
                        move_counter <= 0;
                    end if;
                when 7 => -- Move down once
                    if move_counter < 20 then -- Move for 20 steps
                        Object_Y_pos <= std_logic_vector(unsigned(Object_Y_pos) + 1);
                        move_counter <= move_counter + 1;
                    else
                        move_phase <= move_phase + 1;
                        move_counter <= 0;
                    end if;
                when 8 => -- Move up once
                    if move_counter < 20 then -- Move for 20 steps
                        Object_Y_pos <= std_logic_vector(unsigned(Object_Y_pos) - 1);
                        move_counter <= move_counter + 1;
                    else
                        move_phase <= move_phase + 1;
                        move_counter <= 0;
                    end if;
                when 9 to 10 => -- Move right twice
                    if move_counter < 60 then -- Move for 60 steps
                        Object_X_pos <= std_logic_vector(unsigned(Object_X_pos) + 1);
                        move_counter <= move_counter + 1;
                    else
                        move_phase <= move_phase + 1;
                        move_counter <= 0;
                    end if;
                when 11 to 12 => -- Move left twice
                    if move_counter < 60 then -- Move for 60 steps
                        Object_X_pos <= std_logic_vector(unsigned(Object_X_pos) - 1);
                        move_counter <= move_counter + 1;
                    else
                        move_phase <= 13; -- End of movement sequence
                        move_counter <= 0;
                    end if;
                when 13 => -- End of pattern, set the flag
                    internal_check_flag <= '1'; -- Indicate movement is done
                when others =>
                    null; -- No action in other states
            end case;
        end if;
    end process;

    -- Assign the internal check flag to the output
    check_flag <= internal_check_flag;
    -- Continuous output of the current positions
    xpos <= Object_X_pos;
    ypos <= Object_Y_pos;
    -- Drawing the Yellow Circle process
    process(hcount, vcount, blank)
    begin
        if blank = '0' then
            if (to_integer(unsigned(hcount)) - to_integer(unsigned(Object_X_pos)))**2 +
               (to_integer(unsigned(vcount)) - to_integer(unsigned(Object_Y_pos)))**2 <= (Circle_Radius**2) then
                Red <= "1111";  -- Set red high for yellow color
                Green <= "1111"; -- Set green high for yellow color
                Blue <= "0000"; -- Set blue low
            else
                -- Outside the circle
                Red <= "0000";
                Green <= "0000";
                Blue <= "0000";
            end if;
        end if;
    end process;

end Behavioral;

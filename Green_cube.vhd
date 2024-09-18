library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Wario_Disp is
    Port (
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        vsync       : in STD_LOGIC;
        blank       : in STD_LOGIC;
        hcount, vcount : in STD_LOGIC_VECTOR(10 downto 0);
        btn_up      : in STD_LOGIC;
        btn_down    : in STD_LOGIC;
        btn_left    : in STD_LOGIC;
        btn_right   : in STD_LOGIC;
        xpos        : out STD_LOGIC_VECTOR(10 downto 0);  -- X position output
        ypos        : out STD_LOGIC_VECTOR(10 downto 0);
        Red, Green, Blue : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Wario_Disp;

architecture Behavioral of Wario_Disp is
    -- Constants for screen and image dimensions
    constant WIDTH : integer := 62;
    constant HEIGHT : integer := 65;
    -- Position signals
    signal Object_X_pos : integer range 0 to 640 - WIDTH := 320 - (WIDTH / 2);  -- Center X coordinate
    signal Object_Y_pos : integer range 0 to 480 - HEIGHT := 240 - (HEIGHT / 2); -- Center Y coordinate
    -- ROM interface signals
    signal ROM_ADDRESS : STD_LOGIC_VECTOR(11 downto 0);
    signal ROM_DATA : STD_LOGIC_VECTOR(11 downto 0);

    -- Component declaration for the Wario ROM
    COMPONENT Wario_ROM
        PORT (
            clka : IN STD_LOGIC;
            addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;

begin
    -- Instantiate Wario_ROM component
    wario_rom_instance : Wario_ROM PORT MAP (
        clka => clk,
        addra => ROM_ADDRESS,
        douta => ROM_DATA
    );

    -- Process for movement logic
    process(vsync, reset)
    begin
        if reset = '1' then
            Object_X_pos <= 320 - (WIDTH / 2);
            Object_Y_pos <= 240 - (HEIGHT / 2);
        elsif rising_edge(vsync) then
            if btn_up = '1' and Object_Y_pos > 0 then
                Object_Y_pos <= Object_Y_pos - 1; -- Move up
                 xpos <= std_logic_vector(to_unsigned(Object_X_pos, xPos'length));
                 ypos <= std_logic_vector(to_unsigned(Object_Y_pos, yPos'length));
            elsif btn_down = '1' and Object_Y_pos < 480 - HEIGHT then
                Object_Y_pos <= Object_Y_pos + 1; -- Move down
                 xpos <= std_logic_vector(to_unsigned(Object_X_pos, xPos'length));
                 ypos <= std_logic_vector(to_unsigned(Object_Y_pos, yPos'length));
            end if;
            if btn_left = '1' and Object_X_pos > 0 then
                Object_X_pos <= Object_X_pos - 1; -- Move left
                 xpos <= std_logic_vector(to_unsigned(Object_X_pos, xPos'length));
                 ypos <= std_logic_vector(to_unsigned(Object_Y_pos, yPos'length));
            elsif btn_right = '1' and Object_X_pos < 640 - WIDTH then
                Object_X_pos <= Object_X_pos + 1; -- Move right
                 xpos <= std_logic_vector(to_unsigned(Object_X_pos, xPos'length));
                    ypos <= std_logic_vector(to_unsigned(Object_Y_pos, yPos'length));
            end if;
        end if;
    end process;
    
    xpos <= std_logic_vector(to_unsigned(Object_X_pos, xPos'length));
    ypos <= std_logic_vector(to_unsigned(Object_Y_pos, yPos'length));
    -- Process for image display logic
    process(clk)
    begin
        if rising_edge(clk) then
            if blank = '0' then
                if unsigned(hcount) >= to_unsigned(Object_X_pos, hcount'length) and
                   unsigned(hcount) < to_unsigned(Object_X_pos + WIDTH, hcount'length) and
                   unsigned(vcount) >= to_unsigned(Object_Y_pos, vcount'length) and
                   unsigned(vcount) < to_unsigned(Object_Y_pos + HEIGHT, vcount'length) then

                    -- Calculate the ROM address for the current pixel
                    ROM_ADDRESS <= std_logic_vector(to_unsigned((to_integer(unsigned(vcount)) - Object_Y_pos) * WIDTH + (to_integer(unsigned(hcount)) - Object_X_pos), 12));

                    -- Assign the output color values
                    Red   <= ROM_DATA(11 downto 8);
                    Green <= ROM_DATA(7 downto 4);
                    Blue  <= ROM_DATA(3 downto 0);
                else
                    -- Assign default color (background) outside the image
                    Red   <= (others => '0');
                    Green <= (others => '0');
                    Blue  <= (others => '0');
                end if;
            else
                -- Screen is blank during retrace periods
                Red   <= (others => '0');
                Green <= (others => '0');
                Blue  <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;

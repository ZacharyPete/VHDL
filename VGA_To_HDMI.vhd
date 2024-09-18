library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA_To_HDMI is
    Port (
        clk_100MHz : in STD_LOGIC;
        reset : in STD_LOGIC;
        btn_up : in STD_LOGIC;
        btn_down : in STD_LOGIC;
        btn_left : in STD_LOGIC;
        btn_right : in STD_LOGIC;
        HDMI_clk_p : out STD_LOGIC;
        HDMI_clk_n : out STD_LOGIC;
        HDMI_tx_p : out STD_LOGIC_VECTOR(2 downto 0);
        HDMI_tx_n : out STD_LOGIC_VECTOR(2 downto 0)
    );
end VGA_To_HDMI;

architecture Behavioral of VGA_To_HDMI is
-- -----------------------------------------------------------------
component clk_wiz_0
port(clk_in1,reset : in std_logic; clk_out1,clk_out2,locked : out std_logic);
end component;

component vga_controller_640_60 is
port(rst,pixel_clk : in std_logic; HS,VS,blank : out std_logic;
     hcount,vcount : out std_logic_vector(10 downto 0));
end component;

component static_background is
Port (hcount,vcount : in STD_LOGIC_VECTOR(10 downto 0); blank : in STD_LOGIC;
      Red,Green,Blue : out STD_LOGIC_VECTOR(3 downto 0));
end component;

component Yellow_Circle
    port (
        reset, VS, blank : in STD_LOGIC;
        hcount, vcount : in STD_LOGIC_VECTOR(10 downto 0);
        Red, Green, Blue : out STD_LOGIC_VECTOR(3 downto 0);
        xpos, ypos : out STD_LOGIC_VECTOR(10 downto 0); -- Added position outputs
        check_flag : out STD_LOGIC  -- Condition flag for the title block
    );
end component;


component Wario_Disp
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        vsync : in STD_LOGIC;  
        blank : in STD_LOGIC;
        hcount : in STD_LOGIC_VECTOR(10 downto 0);
        vcount : in STD_LOGIC_VECTOR(10 downto 0);
        btn_up : in STD_LOGIC;
        btn_down : in STD_LOGIC;
        btn_left : in STD_LOGIC;
        btn_right : in STD_LOGIC;
        Red : out STD_LOGIC_VECTOR(3 downto 0);
        Green : out STD_LOGIC_VECTOR(3 downto 0);
        Blue : out STD_LOGIC_VECTOR(3 downto 0);
        xpos, ypos : out STD_LOGIC_VECTOR(10 downto 0) -- Added position outputs
    );
end component;




    component title_block
        generic (
            X_win_start : integer;
            Y_win_start : integer;
            SIZE : integer
        );
        port (
            clk, reset, blank : in STD_LOGIC;
            hcount, vcount : in STD_LOGIC_VECTOR(10 downto 0);
            RedCubeX    : in STD_LOGIC_VECTOR(10 downto 0); -- Added
            RedCubeY    : in STD_LOGIC_VECTOR(10 downto 0); -- Added
            GreenCubeX  : in STD_LOGIC_VECTOR(10 downto 0); -- Added
            GreenCubeY  : in STD_LOGIC_VECTOR(10 downto 0); -- Added
            RedStopped  : in STD_LOGIC; -- Assumed input to decide on win/loss
            Red, Green, Blue : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

component merge_display is
Port (Red_a,Red_b,Red_c,Red_d,Red_e : in STD_LOGIC_VECTOR(3 downto 0);
      Green_a,Green_b,Green_c,Green_d,Green_e : in STD_LOGIC_VECTOR(3 downto 0);
      Blue_a,Blue_b,Blue_c,Blue_d,Blue_e : in STD_LOGIC_VECTOR(3 downto 0);
      R3,R2,R1,R0,G3,G2,G1,G0,B3,B2,B1,B0 : out STD_LOGIC);
end component;

COMPONENT hdmi_tx_0
  PORT (
    pix_clk : IN STD_LOGIC;
    pix_clkx5 : IN STD_LOGIC;
    pix_clk_locked : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    red : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    green : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    blue : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    hsync : IN STD_LOGIC;
    vsync : IN STD_LOGIC;
    vde : IN STD_LOGIC;
    aux0_din : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    aux1_din : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    aux2_din : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    ade : IN STD_LOGIC;
    TMDS_CLK_P : OUT STD_LOGIC;
    TMDS_CLK_N : OUT STD_LOGIC;
    TMDS_DATA_P : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    TMDS_DATA_N : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END COMPONENT;

-- --------------------------------------------------------------------
signal CLK_25MHz,CLK_125MHz,blank,locked : STD_LOGIC;
signal hcount,vcount : STD_LOGIC_VECTOR(10 downto 0);
signal HSYNC, VSYNC : STD_LOGIC;
signal vde : STD_LOGIC;
signal RED3,RED2,RED1,RED0 : STD_LOGIC;
signal GREEN3,GREEN2,GREEN1,GREEN0 : STD_LOGIC;
signal BLUE3,BLUE2,BLUE1,BLUE0 : STD_LOGIC;
signal RED, GREEN, BLUE : STD_LOGIC_VECTOR(3 downto 0);
signal RED_s,GREEN_s,BLUE_s : STD_LOGIC_VECTOR(3 downto 0);
signal RED_b,GREEN_b,BLUE_b : STD_LOGIC_VECTOR(3 downto 0);
signal RED_r,GREEN_r,BLUE_r : STD_LOGIC_VECTOR(3 downto 0);
signal RED_g,GREEN_g,BLUE_g : STD_LOGIC_VECTOR(3 downto 0);
signal RED_m,GREEN_m,BLUE_m : STD_LOGIC_VECTOR(3 downto 0);
signal  VS : STD_LOGIC;
signal check_flag : STD_LOGIC;  -- Condition flag from Red_cube 
signal GreenCubeX, GreenCubeY: STD_LOGIC_VECTOR(10 downto 0);
signal RedCubeX, RedCubeY: STD_LOGIC_VECTOR(10 downto 0);

begin
-- ------ Cannot pass these directly during instantiation ------
vde <= not blank;
RED <= (RED3 & RED2 & RED1 & RED0);
GREEN <= (GREEN3 & GREEN2 & GREEN1 & GREEN0);
BLUE <= (BLUE3 & BLUE2 & BLUE1 & BLUE0);
-- --------------------------------------------------------------

C1: clk_wiz_0 PORT MAP (clk_out1 => CLK_25MHz, clk_out2 => CLK_125MHz, reset => reset, locked => locked, clk_in1 => clk_100MHz);  

V1 : vga_controller_640_60 PORT MAP (pixel_clk => CLK_25MHz, rst => reset, HS => HSYNC, VS => VSYNC, blank => blank, hcount => hcount, 
                                     vcount => vcount);

S1 : static_background PORT MAP (hcount => hcount, vcount => vcount, blank => blank, RED => RED_s, GREEN => GREEN_s, BLUE => BLUE_s);

  -- Red Cube
    Yellow_Cirlce: Yellow_circle
        port map (
            reset => reset,
            VS => vsync,
            blank => blank,
            hcount => hcount,
            vcount => vcount,
            Red => red_r,
            Green => green_r,
            Blue => blue_r,
            xPos => RedCubeX,
            yPos => RedCubeY, 
            check_flag => check_flag  -- Connecting the check flag
        );

 -- Component Instantiation of Keypad_Controller

        
 Wario : Wario_Disp PORT MAP (
    clk => CLK_25MHz,  -- Assuming this is the appropriate clock signal
    reset => reset,
    vsync => VSYNC,  -- Make sure VSYNC is correctly connected from the VGA controller
    blank => blank,
    hcount => hcount,
    vcount => vcount,
    btn_up => btn_up,
    btn_down => btn_down,
    btn_left => btn_left,
    btn_right => btn_right,
    Red => RED_g,  -- Connect these signals to merging/display logic as needed
    Green => GREEN_g,
    Blue => BLUE_g,
    xpos => GreenCubeX,
    yPos => GreenCubeY
);


-- Title Block
    title_block_inst: title_block
        generic map (
            X_win_start => 224,  -- Specify as needed
            Y_win_start => 32,   -- Specify as needed
            SIZE => 32           -- Specify as needed
        )
        port map (
            clk => clk_25MHz,
            reset => reset,
            blank => blank,
            hcount => hcount,
            vcount => vcount,
            RedCubeX => RedCubeX, -- Added
            RedCubeY => RedCubeY, -- Added
            GreenCubeX => GreenCubeX, -- Added
            GreenCubeY => GreenCubeY, -- Added
            RedStopped => check_flag, -- Use this or another appropriate signal
            Red => red_m,
            Green => green_m,
            Blue => blue_m
        );
M1 : merge_display PORT MAP (Red_a => RED_s, Red_b => RED_b, Red_c => RED_r, Red_d => RED_g, Red_e => RED_m,
                             Green_a => GREEN_s, Green_b => GREEN_b, Green_c => GREEN_r, Green_d => GREEN_g, Green_e => GREEN_m,
                             Blue_a => BLUE_s, Blue_b => BLUE_b, Blue_c => BLUE_r, Blue_d => BLUE_g, Blue_e => BLUE_m, 
                             R3 => RED3, R2 => RED2, R1 => RED1, R0 => RED0, G3 => GREEN3, G2 => GREEN2, G1 => GREEN1, G0 => GREEN0, 
                             B3 => BLUE3, B2 => BLUE2, B1 => BLUE1, B0 => BLUE0);
                               
H1 : hdmi_tx_0 PORT MAP (pix_clk => CLK_25MHz, pix_clkx5 => CLK_125MHz, pix_clk_locked => locked, rst => reset,
                         red => RED, green => GREEN, blue => BLUE, hsync => HSYNC, vsync => VSYNC, vde => vde,
                         aux0_din => X"0", aux1_din => X"0", aux2_din => X"0", ade => '0',
                         TMDS_CLK_P => HDMI_clk_p, TMDS_CLK_N => HDMI_clk_n, TMDS_DATA_P => HDMI_tx_p, TMDS_DATA_N => HDMI_tx_n);
 

end Behavioral;

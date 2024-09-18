library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- DOORLOCK entity declaration
entity DOORLOCK is
    Port (
        CLK           : in STD_LOGIC;
        RESET         : in STD_LOGIC;
        SWITCHES      : in STD_LOGIC_VECTOR(7 downto 0);
        BTN2          : in STD_LOGIC;
        BTN1          : in STD_LOGIC;
        BTN0          : in STD_LOGIC;
        RIGHT_ANODE   : out STD_LOGIC_VECTOR(3 downto 0);
        LEFT_ANODE    : out STD_LOGIC_VECTOR(3 downto 0);
        RIGHT_SEGMENT : out STD_LOGIC_VECTOR(7 downto 0);
        LEFT_SEGMENT  : out STD_LOGIC_VECTOR(7 downto 0) 
    );
end DOORLOCK;

architecture Behavioral of DOORLOCK is
    type T_State is (INIT, DISPLAY_L, DISPLAY_O, DISPLAY_C, DISPLAY_K, WAIT_INPUT, CHECK_CODE, DISPLAY_O1, DISPLAY_P, DISPLAY_E, DISPLAY_N, DISPLAY_E1, DISPLAY_R1, DISPLAY_R2, UNLOCKED, LOCKED, ERROR_STATE);
    signal state, next_state : T_State := INIT;
    signal entered_code : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal code_input_count : INTEGER range 0 to 3 := 0;
    signal locked_code : STD_LOGIC_VECTOR(7 downto 0);
    signal code_latched : BOOLEAN := FALSE;

begin
    -- Button press detection and code latching
    process(CLK, RESET)
    begin
        if RESET = '1' then
            state <= INIT;
            code_latched <= FALSE;
            LEFT_ANODE <= (others => '1'); -- Ensure left anodes and segments are off
            LEFT_SEGMENT <= (others => '1');
        elsif rising_edge(CLK) then
            state <= next_state;
            case state is
                when INIT =>
                    next_state <= DISPLAY_L;

                when DISPLAY_L =>
                    RIGHT_ANODE <= "0111"; RIGHT_SEGMENT <= "11000111"; -- L
                    next_state <= DISPLAY_O;

                when DISPLAY_O =>
                    RIGHT_ANODE <= "1011"; RIGHT_SEGMENT <= "11000000"; -- O
                    next_state <= DISPLAY_C;

                when DISPLAY_C =>
                    RIGHT_ANODE <= "1101"; RIGHT_SEGMENT <= "11000110"; -- C
                    next_state <= DISPLAY_K;

                when DISPLAY_K =>
                    RIGHT_ANODE <= "1110"; RIGHT_SEGMENT <= "00001001"; -- K
                    RIGHT_ANODE <= "1111"; -- Turn off after displaying K
                    next_state <= WAIT_INPUT;

                when WAIT_INPUT =>
                    if (BTN0 = '1' or BTN1 = '1' or BTN2 = '1') and not code_latched then
                        locked_code <= SWITCHES; -- Latch the code on first button press
                        code_latched <= TRUE;
                    end if;

                    if code_latched then
                        if BTN0 = '1' then
                            entered_code(code_input_count * 2 + 1 downto code_input_count * 2) <= "00";
                        elsif BTN1 = '1' then
                            entered_code(code_input_count * 2 + 1 downto code_input_count * 2) <= "01";
                        elsif BTN2 = '1' then
                            entered_code(code_input_count * 2 + 1 downto code_input_count * 2) <= "10";
                        end if;

                        code_input_count <= code_input_count + 1;
                        if code_input_count = 3 then
                            next_state <= CHECK_CODE;
                        end if;
                    end if;

                when CHECK_CODE =>
                    if entered_code = locked_code then
                        next_state <= DISPLAY_O1;
                    else
                        next_state <= DISPLAY_E1;
                    end if;
                -- Sequence for "OPEN"
                when DISPLAY_O1 =>
                    RIGHT_ANODE <= "0111"; RIGHT_SEGMENT <= "11000000"; -- O
                    next_state <= DISPLAY_P;

                when DISPLAY_P =>
                    RIGHT_ANODE <= "1011"; RIGHT_SEGMENT <= "10001100"; -- P
                    next_state <= DISPLAY_E;

                when DISPLAY_E =>
                    RIGHT_ANODE <= "1101"; RIGHT_SEGMENT <= "10000110"; -- E
                    next_state <= DISPLAY_N;

                when DISPLAY_N =>
                    RIGHT_ANODE <= "1110"; RIGHT_SEGMENT <= "10101011"; -- N
                    RIGHT_ANODE <= "1111";
                    next_state <= INIT;

                -- Sequence for "ERROR"
                when DISPLAY_E1 =>
                    RIGHT_ANODE <= "1011"; RIGHT_SEGMENT <= "10000110"; -- E
                    next_state <= DISPLAY_R1;

                when DISPLAY_R1 =>
                    RIGHT_ANODE <= "1101"; RIGHT_SEGMENT <= "10101111"; -- R
                    next_state <= DISPLAY_R2;

                when DISPLAY_R2 =>
                    RIGHT_ANODE <= "1110"; RIGHT_SEGMENT <= "10101111"; -- R
                    RIGHT_ANODE <= "1111";
                    next_state <= INIT;

                when others =>
                    next_state <= INIT;
            end case;
        end if;
    end process;
end Behavioral;

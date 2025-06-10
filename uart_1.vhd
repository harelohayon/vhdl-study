
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_1 is
    port (
        clk      : in std_logic;
        RXD      : in std_logic;
        resetN   : in std_logic;
        data_out : buffer std_logic_vector(7 downto 0);
        LEDG     : out std_logic_vector(7 downto 0);
        led      : out std_logic;
        HEX0_D   : out std_logic_vector(6 downto 0);
        HEX1_D   : out std_logic_vector(6 downto 0);
        HEX2_D   : out std_logic_vector(6 downto 0);
        txd      : out std_logic
    );
end;

architecture rec of uart_1 is
    constant FOSC : integer := 50000000;
    constant Boud : integer := 9600;
    constant T    : integer := FOSC / Boud;
    constant BAUD_TICK : integer := T;

    type state_type is (s0, s1);
    signal state  : state_type := s0;
    signal Sbuf   : std_logic_vector(7 downto 0);
    signal cnt    : integer range 0 to 10*T := 0;

    signal digit0, digit1, digit2 : integer range 0 to 9;

    signal computer  : std_logic_vector(9 downto 0);
    signal bit1      : integer range 0 to 10 := 0;
    signal counter   : integer := 0;
    signal sendto    : std_logic_vector(7 downto 0) := (others => '0');

    signal last_data : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_ready  : std_logic := '0';

    function digit_to_7seg(d : integer) return std_logic_vector is
    begin
        case d is 
            when 0 => return "1000000";
            when 1 => return "1111001";
            when 2 => return "0100100";
            when 3 => return "0110000";
            when 4 => return "0011001";
            when 5 => return "0010010";
            when 6 => return "0000010";
            when 7 => return "1111000";
            when 8 => return "0000000";
            when 9 => return "0010000";
            when 10 => return "0001000"; -- A
            when 11 => return "0000011"; -- B
            when 12 => return "1000110"; -- C
            when 13 => return "0100001"; -- D
            when 14 => return "0000110"; -- E
            when 15 => return "0001110"; -- F
            when others => return "1111111"; 
        end case;
    end function;

begin

    -- קבלת UART
    process(clk)
    begin
        if rising_edge(clk) then
            if resetN = '0' then
                state <= s0;
                cnt   <= 0;
                led   <= '0';
            else
                led <= '1';
                case state is
                    when s0 =>
                        cnt <= 0;
                        if RXD = '0' then
                            state <= s1;
                        end if;
                    when s1 =>
                        if cnt < 10*T then
                            cnt <= cnt + 1;
                        else
                            state <= s0;
                        end if;

                        if cnt = T/2 and RXD = '1' then
                            state <= s0;
                        elsif cnt = T/2 + 1*T then Sbuf(0) <= RXD;
                        elsif cnt = T/2 + 2*T then Sbuf(1) <= RXD;
                        elsif cnt = T/2 + 3*T then Sbuf(2) <= RXD;
                        elsif cnt = T/2 + 4*T then Sbuf(3) <= RXD;
                        elsif cnt = T/2 + 5*T then Sbuf(4) <= RXD;
                        elsif cnt = T/2 + 6*T then Sbuf(5) <= RXD;
                        elsif cnt = T/2 + 7*T then Sbuf(6) <= RXD;
                        elsif cnt = T/2 + 8*T then Sbuf(7) <= RXD;
                        elsif cnt = 10*T then
                            data_out <= Sbuf;
                            sendto   <= Sbuf;
                            state    <= s0;
                        end if;
                end case;
            end if;
        end if;
    end process;

    LEDG <= sendto when resetN = '1' else (others => '0');
    
    process(sendto)
        variable x : integer;
    begin
        x := to_integer(unsigned(sendto));
        digit2 <= x / 100;
        digit1 <= (x / 10) mod 10;
        digit0 <= x mod 10;
    end process;

    HEX0_D <= digit_to_7seg(digit0);
    HEX1_D <= digit_to_7seg(digit1);
    HEX2_D <= digit_to_7seg(digit2);

    -- שידור UART TX
    process(clk)
    begin
        if rising_edge(clk) then
            if resetN = '0' then
                txd      <= '1';
                bit1     <= 0;
                counter  <= 0;
                tx_ready <= '0';
            else
                -- טריגר: תו חדש לשידור
                if sendto /= last_data then
                    tx_ready  <= '1';
                    last_data <= sendto;
                end if;

                -- התחלת שידור
                if tx_ready = '1' and bit1 = 0 then
                    computer <= '0' & sendto & '1'; -- Start + 8 Bits + Stop
                    txd      <= '0';
                    bit1     <= 1;
                    counter  <= 0;
                    tx_ready <= '0';
                elsif bit1 >= 1 and bit1 <= 9 then
                    if counter = BAUD_TICK - 1 then
                        txd     <= computer(bit1);
                        bit1    <= bit1 + 1;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                elsif bit1 = 10 then
                    txd  <= '1';
                    bit1 <= 0;
                end if;
            end if;
        end if;
    end process;

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_seg is
    port (
        score : in  integer range 0 to 9999;
        lives : in  integer range 0 to 3;
        hex0  : out std_logic_vector(6 downto 0);
        hex1  : out std_logic_vector(6 downto 0);
        hex2  : out std_logic_vector(6 downto 0);
        hex3  : out std_logic_vector(6 downto 0);
        hex4  : out std_logic_vector(6 downto 0)
    );
end seven_seg;

architecture behavior of seven_seg is

    function dec(d : integer) return std_logic_vector is
        variable s : std_logic_vector(6 downto 0);
    begin
        case d is
            when 0 => s := "1000000";
            when 1 => s := "1111001";
            when 2 => s := "0100100";
            when 3 => s := "0110000";
            when 4 => s := "0011001";
            when 5 => s := "0010010";
            when 6 => s := "0000010";
            when 7 => s := "1111000";
            when 8 => s := "0000000";
            when 9 => s := "0010000";
            when others => s := "1111111";
        end case;
        return s;
    end function;

begin

    hex0 <= dec(score mod 10);
    hex1 <= dec((score / 10) mod 10);
    hex2 <= dec((score / 100) mod 10);
    hex3 <= dec((score / 1000) mod 10);
    hex4 <= dec(lives);

end behavior;

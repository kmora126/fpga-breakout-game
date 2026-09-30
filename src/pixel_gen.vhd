library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pixel_gen is
    port (
        video_on   : in  std_logic;
        pixel_x    : in  integer range 0 to 799;
        pixel_y    : in  integer range 0 to 524;
        paddle_x   : in  integer range 0 to 639;
        ball_x     : in  integer range 0 to 639;
        ball_y     : in  integer range 0 to 479;
        bricks     : in  std_logic_vector(47 downto 0);
        game_state : in  std_logic_vector(1 downto 0);
        red        : out std_logic_vector(7 downto 0);
        green      : out std_logic_vector(7 downto 0);
        blue       : out std_logic_vector(7 downto 0)
    );
end pixel_gen;

architecture behavior of pixel_gen is

    signal rgb : std_logic_vector(23 downto 0);

    signal in_pad   : boolean;
    signal in_ball  : boolean;
    signal in_brick : boolean;
    signal bcolor   : std_logic_vector(23 downto 0);

begin

    in_pad <= (pixel_x >= paddle_x) and (pixel_x < paddle_x + 80) and
              (pixel_y >= 440) and (pixel_y < 450);

    in_ball <= (pixel_x >= ball_x) and (pixel_x < ball_x + 8) and
               (pixel_y >= ball_y) and (pixel_y < ball_y + 8);

    process(pixel_x, pixel_y, bricks)
        variable r : integer range 0 to 5;
        variable c : integer range 0 to 7;
    begin
        in_brick <= false;
        bcolor <= x"FF0000";

        if (pixel_x >= 40) and (pixel_x < 600) and
           (pixel_y >= 60) and (pixel_y < 180) then

            c := (pixel_x - 40) / 70;
            r := (pixel_y - 60) / 20;

            if bricks(r * 8 + c) = '1' then
                if ((pixel_x - 40) mod 70) > 1 and
                   ((pixel_y - 60) mod 20) > 1 then
                    in_brick <= true;
                    case r is
                        when 0 => bcolor <= x"FF0000";
                        when 1 => bcolor <= x"FF00FF";
                        when 2 => bcolor <= x"FFFF00";
                        when 3 => bcolor <= x"00FF00";
                        when 4 => bcolor <= x"00FFFF";
                        when others => bcolor <= x"0000FF";
                    end case;
                end if;
            end if;
        end if;
    end process;

    process(video_on, game_state, in_pad, in_ball, in_brick, bcolor)
    begin
        if video_on = '0' then
            rgb <= (others => '0');
        else
            case game_state is
                when "00" =>
                    rgb <= x"7F7F7F";
                when "01" =>
                    if in_ball then
                        rgb <= (others => '1');
                    elsif in_pad then
                        rgb <= (others => '1');
                    elsif in_brick then
                        rgb <= bcolor;
                    else
                        rgb <= (others => '0');
                    end if;
                when "10" =>
                    rgb <= x"00FF00";
                when "11" =>
                    rgb <= x"FF0000";
                when others =>
                    rgb <= (others => '0');
            end case;
        end if;
    end process;

    red   <= rgb(23 downto 16);
    green <= rgb(15 downto 8);
    blue  <= rgb(7 downto 0);

end behavior;

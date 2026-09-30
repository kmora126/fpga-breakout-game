library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_logic is
    port (
        clk_25     : in  std_logic;
        reset      : in  std_logic;
        vsync_tick : in  std_logic;
        key_left   : in  std_logic;
        key_right  : in  std_logic;
        key_start  : in  std_logic;
        paddle_x   : out integer range 0 to 639;
        ball_x     : out integer range 0 to 639;
        ball_y     : out integer range 0 to 479;
        bricks     : out std_logic_vector(47 downto 0);
        game_state : out std_logic_vector(1 downto 0);
        score      : out integer range 0 to 9999;
        lives      : out integer range 0 to 3
    );
end game_logic;

architecture behavior of game_logic is

    signal state : std_logic_vector(1 downto 0) := "00";
    -- 00 = idle, 01 = play, 10 = win, 11 = lose

    signal vsync_d : std_logic := '0';
    signal tick    : std_logic := '0';

    signal pad : integer range 0 to 639 := 280;
    signal bx  : integer range 0 to 639 := 320;
    signal by  : integer range 0 to 479 := 300;
    signal dx  : integer range -3 to 3 := 2;
    signal dy  : integer range -3 to 3 := -2;

    signal br : std_logic_vector(47 downto 0) := (others => '1');
    signal sc : integer range 0 to 9999 := 0;
    signal lv : integer range 0 to 3 := 3;

begin

    process(clk_25, reset)
    begin
        if reset = '1' then
            vsync_d <= '0';
            tick    <= '0';
        elsif rising_edge(clk_25) then
            vsync_d <= vsync_tick;
            if vsync_tick = '1' and vsync_d = '0' then
                tick <= '1';
            else
                tick <= '0';
            end if;
        end if;
    end process;

    process(clk_25, reset)
        variable nx : integer range -10 to 650;
        variable ny : integer range -10 to 490;
        variable c  : integer range 0 to 7;
        variable r  : integer range 0 to 5;
        variable idx : integer range 0 to 47;
        variable alive : boolean;
    begin
        if reset = '1' then
            state <= "00";
            pad <= 280;
            bx  <= 320;
            by  <= 300;
            dx  <= 2;
            dy  <= -2;
            br  <= (others => '1');
            sc  <= 0;
            lv  <= 3;

        elsif rising_edge(clk_25) then
            if tick = '1' then

                case state is

                    when "00" =>
                        pad <= 280;
                        bx <= 320;
                        by <= 300;
                        dx <= 2;
                        dy <= -2;
                        br <= (others => '1');
                        sc <= 0;
                        lv <= 3;
                        if key_start = '1' then
                            state <= "01";
                        end if;

                    when "01" =>
                        if key_left = '1' and pad > 4 then
                            pad <= pad - 4;
                        elsif key_right = '1' and pad < 556 then
                            pad <= pad + 4;
                        end if;

                        nx := bx + dx;
                        ny := by + dy;

                        if nx <= 0 then
                            nx := 0;
                            dx <= -dx;
                        end if;

                        if nx >= 632 then
                            nx := 632;
                            dx <= -dx;
                        end if;

                        if ny <= 0 then
                            ny := 0;
                            dy <= -dy;
                        end if;

                        -- paddle hit
                        if (ny + 8 >= 440) and (ny + 8 <= 450) and
                           (nx + 8 >= pad) and (nx <= pad + 80) and (dy > 0) then
                            dy <= -dy;
                            ny := 432;
                        end if;

                        -- ball missed
                        if ny >= 479 then
                            if lv = 1 then
                                lv <= 0;
                                state <= "11";
                            else
                                lv <= lv - 1;
                                nx := 320;
                                ny := 300;
                                dx <= 2;
                                dy <= -2;
                            end if;
                        end if;

                        -- brick hit
                        if (nx + 4 >= 40) and (nx + 4 < 600) and
                           (ny + 4 >= 60) and (ny + 4 < 180) then
                            c := (nx + 4 - 40) / 70;
                            r := (ny + 4 - 60) / 20;
                            idx := r * 8 + c;
                            if br(idx) = '1' then
                                br(idx) <= '0';
                                dy <= -dy;
                                if sc < 9990 then
                                    sc <= sc + 10;
                                end if;
                            end if;
                        end if;

                        alive := false;
                        for i in 0 to 47 loop
                            if br(i) = '1' then
                                alive := true;
                            end if;
                        end loop;
                        if not alive then
                            state <= "10";
                        end if;

                        bx <= nx;
                        by <= ny;

                    when "10" =>
                        if key_start = '1' then
                            state <= "00";
                        end if;

                    when "11" =>
                        if key_start = '1' then
                            state <= "00";
                        end if;

                    when others =>
                        state <= "00";
                end case;
            end if;
        end if;
    end process;

    paddle_x   <= pad;
    ball_x     <= bx;
    ball_y     <= by;
    bricks     <= br;
    game_state <= state;
    score      <= sc;
    lives      <= lv;

end behavior;

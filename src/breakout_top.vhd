library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity breakout_top is
    port (
        CLOCK_50    : in  std_logic;
        KEY         : in  std_logic_vector(3 downto 0);
        VGA_R       : out std_logic_vector(7 downto 0);
        VGA_G       : out std_logic_vector(7 downto 0);
        VGA_B       : out std_logic_vector(7 downto 0);
        VGA_HS      : out std_logic;
        VGA_VS      : out std_logic;
        VGA_BLANK_N : out std_logic;
        VGA_SYNC_N  : out std_logic;
        VGA_CLK     : out std_logic;
        HEX0        : out std_logic_vector(6 downto 0);
        HEX1        : out std_logic_vector(6 downto 0);
        HEX2        : out std_logic_vector(6 downto 0);
        HEX3        : out std_logic_vector(6 downto 0);
        HEX4        : out std_logic_vector(6 downto 0)
    );
end breakout_top;

architecture structure of breakout_top is

    signal clk_25 : std_logic;
    signal rst    : std_logic;

    signal hs, vs, von : std_logic;
    signal px : integer range 0 to 799;
    signal py : integer range 0 to 524;

    signal pad : integer range 0 to 639;
    signal bx  : integer range 0 to 639;
    signal by  : integer range 0 to 479;
    signal br  : std_logic_vector(47 downto 0);
    signal st  : std_logic_vector(1 downto 0);

    signal sc : integer range 0 to 9999;
    signal lv : integer range 0 to 3;

    signal kl, kr, ks : std_logic;

    component clock_div
        port (
            clk_50 : in  std_logic;
            reset  : in  std_logic;
            clk_25 : out std_logic
        );
    end component;

    component vga_controller
        port (
            clk_25   : in  std_logic;
            reset    : in  std_logic;
            hsync    : out std_logic;
            vsync    : out std_logic;
            video_on : out std_logic;
            pixel_x  : out integer range 0 to 799;
            pixel_y  : out integer range 0 to 524
        );
    end component;

    component game_logic
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
    end component;

    component pixel_gen
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
    end component;

    component seven_seg
        port (
            score : in  integer range 0 to 9999;
            lives : in  integer range 0 to 3;
            hex0  : out std_logic_vector(6 downto 0);
            hex1  : out std_logic_vector(6 downto 0);
            hex2  : out std_logic_vector(6 downto 0);
            hex3  : out std_logic_vector(6 downto 0);
            hex4  : out std_logic_vector(6 downto 0)
        );
    end component;

begin

    rst <= not KEY(3);
    kr  <= not KEY(0);
    ks  <= not KEY(1);
    kl  <= not KEY(2);

    U1: clock_div port map (CLOCK_50, rst, clk_25);

    U2: vga_controller port map (clk_25, rst, hs, vs, von, px, py);

    U3: game_logic port map (
        clk_25, rst, vs, kl, kr, ks,
        pad, bx, by, br, st, sc, lv
    );

    U4: pixel_gen port map (
        von, px, py, pad, bx, by, br, st,
        VGA_R, VGA_G, VGA_B
    );

    U5: seven_seg port map (sc, lv, HEX0, HEX1, HEX2, HEX3, HEX4);

    VGA_HS      <= hs;
    VGA_VS      <= vs;
    VGA_BLANK_N <= von;
    VGA_SYNC_N  <= '0';
    VGA_CLK     <= clk_25;

end structure;

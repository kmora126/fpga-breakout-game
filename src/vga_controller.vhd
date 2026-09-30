library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is
    port (
        clk_25   : in  std_logic;
        reset    : in  std_logic;
        hsync    : out std_logic;
        vsync    : out std_logic;
        video_on : out std_logic;
        pixel_x  : out integer range 0 to 799;
        pixel_y  : out integer range 0 to 524
    );
end vga_controller;

architecture behavior of vga_controller is
    -- 640x480 @ 60Hz
    signal hc : integer range 0 to 799 := 0;
    signal vc : integer range 0 to 524 := 0;
begin

    process(clk_25, reset)
    begin
        if reset = '1' then
            hc <= 0;
            vc <= 0;
        elsif rising_edge(clk_25) then
            if hc = 799 then
                hc <= 0;
                if vc = 524 then
                    vc <= 0;
                else
                    vc <= vc + 1;
                end if;
            else
                hc <= hc + 1;
            end if;
        end if;
    end process;

    hsync <= '0' when (hc >= 656 and hc < 752) else '1';
    vsync <= '0' when (vc >= 490 and vc < 492) else '1';

    video_on <= '1' when (hc < 640 and vc < 480) else '0';

    pixel_x <= hc;
    pixel_y <= vc;

end behavior;

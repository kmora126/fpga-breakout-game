library ieee;
use ieee.std_logic_1164.all;

entity clock_div is
    port (
        clk_50 : in  std_logic;
        reset  : in  std_logic;
        clk_25 : out std_logic
    );
end clock_div;

architecture behavior of clock_div is
    signal t : std_logic := '0';
begin
    process(clk_50, reset)
    begin
        if reset = '1' then
            t <= '0';
        elsif rising_edge(clk_50) then
            t <= not t;
        end if;
    end process;

    clk_25 <= t;
end behavior;

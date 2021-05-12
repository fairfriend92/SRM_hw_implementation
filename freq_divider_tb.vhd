library ieee;
use ieee.std_logic_1164.all;

entity freq_divider_tb is
end freq_divider_tb;

architecture test of freq_divider_tb is
  component freq_divider
    generic(factor: integer);
    port(
      clk, rst: in std_logic;
      clk_div: out std_logic
      );
  end component;
  constant factor: integer:= 3;
  constant master_clk: time:= 10 ns;
  signal clk, clk_div, rst: std_logic;
begin
  master_clk_gen: process
  begin
    clk<= '0';
    wait for master_clk/2;
    clk<= '1';
    wait for master_clk/2;
  end process master_clk_gen;
  test: process
  begin
    rst<= '0';
    wait for master_clk*(factor+1); -- we want the level of rst to go high
    -- the output of the dut in order to appreciate the effect of the reset,
    -- which otherwise would go unnoticed
    rst<= '1';
    wait for master_clk;
    rst<= '0';
    wait for master_clk*4*factor; -- before repeating the whole test we wait
    -- for a number of clk periods big enough to observe two periods of clk_div 
  end process test;
  dut: freq_divider
    generic map(factor=> factor)
    port map(rst=> rst, clk=> clk, clk_div=> clk_div);
end architecture test;


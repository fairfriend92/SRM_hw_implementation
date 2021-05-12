library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exc_synapse_tb is
end exc_synapse_tb;

architecture test of exc_synapse_tb is
  component exc_synapse
    port(
      clk, exc_spike: in std_logic;
      exc_pot: out std_logic_vector (32-1 downto 0)
      );
  end component;
  constant clk_period: time:= 10 ns;
  signal clk, exc_spike: std_logic;
  signal exc_pot: std_logic_vector (32-1 downto 0);
begin
  clk_gen: process
  begin
    clk<= '1';
    wait for clk_period/2;
    clk<= '0';
    wait for clk_period/2;
  end process clk_gen;
  synapse_test: process
  begin
    exc_spike<= '1';
    wait for clk_period;
    exc_spike<= '0';
    wait for 16*clk_period;
    exc_spike<= '1';
    wait for clk_period;
    exc_spike<= '0';
    wait for 32*clk_period;
  end process synapse_test;
  dut: exc_synapse
    port map(
      clk=> clk, exc_spike=> exc_spike, exc_pot=> exc_pot
      );
end architecture test;

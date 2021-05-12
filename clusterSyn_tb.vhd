library ieee;
use ieee.std_logic_1164.all;
use work.fixpt_lib.all;

entity clusterSyn_tb is
  port(current_word: out std_logic_vector(32-1 downto 0):= (others=> '0'));
end clusterSyn_tb;

architecture test of clusterSyn_tb is
  component clusterSyn
    generic(numSyn, addrWidth: integer; dataPath_lut: string);
    port(
      clk, clk_div: in std_logic;
      spike: in std_logic_vector (numSyn-1 downto 0);
      current: out fixpt_word:= (scale=> 19, word=> (others=> '0'))
      );
  end component;

  constant numSyn: integer:= 3;
  constant addrWidth: integer:= 6;
  constant dataPath_lut: string:= "./textfiles/excSyn.txt";

  component freq_divider
    generic(factor: integer);
    port(
      clk, rst: in std_logic;
      clk_div: out std_logic
      );
  end component;

  constant factor: integer:= 5*numSyn;
  constant clk_period: time:= 10 ns;
  signal clk, clk_div, rst: std_logic;
  signal spike: std_logic_vector (numSyn-1 downto 0);
  signal current: fixpt_word;

begin

  clk_gen: process
  begin
    clk<= '1';
    wait for clk_period/2;
    clk<= '0';
    wait for clk_period/2;
  end process clk_gen;

  spike_arrival: process
  begin
    rst<= '0';
    spike<= "000";
    wait for factor*clk_period;
    spike<= "101";
    wait for factor*clk_period;
    spike<= "000";
    wait for 32*factor*clk_period;
  end process spike_arrival;
  
  current_sampling: process
  begin
    current_word<= std_logic_vector(current.word);
    wait for clk_period;
  end process current_sampling;

  freq_divider_test: freq_divider
    generic map(factor=> factor)
    port map(clk=> clk, clk_div=> clk_div, rst=> rst);

  dut: clusterSyn
    generic map(
      numSyn=> numSyn, addrWidth=> addrWidth, dataPath_lut=> dataPath_lut
      )
    port map(clk=> clk, clk_div=> clk_div, spike=> spike, current=> current);

  end architecture test;
    
    
  
  

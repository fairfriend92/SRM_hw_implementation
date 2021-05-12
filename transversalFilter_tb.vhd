library ieee;
use ieee.std_logic_1164.all;
use work.fixpt_lib.all;

entity transversalFilter_tb is
  port(potential: out std_logic_vector(32-1 downto 0):= (others=> '0'));
end transversalFilter_tb;

architecture test of transversalFilter_tb is

  component transversalFilter
    generic(order, dataWidth: integer; weightRom_path: string);
    port(
      clk, clk_div: in std_logic;
      dataIn: in fixpt_word:= (scale=> 19, word=> (others=> '0'));
      dataOut: out fixpt_word:= (scale=> 19, word=> (others=> '0'))
      );
  end component transversalFilter;

  constant order: integer:= 256;
  constant dataWidth: integer:= 32;
  constant weightRom_path: string:= "./textfiles/filter.txt";
  signal dataIn: fixpt_word:= (scale=> 19, word=> (others=> '0'));
  signal dataOut: fixpt_word:= (scale=> 19, word=> (others=> '0'));

  component freq_divider
    generic(factor: integer);
    port(
      clk, rst: in std_logic;
      clk_div: out std_logic
      );
  end component;

  constant factor: integer:= 5;
  constant clk_period: time:= 10 ns;
  signal clk, clk_div, rst: std_logic;

begin
  
  clk_gen: process
  begin
    clk<= '1';
    wait for clk_period/2;
    clk<= '0';
    wait for clk_period/2;
  end process clk_gen;

  filtering: process
  begin
    dataIn.word<= "00000000000000000000000000000000";
    wait for factor*clk_period;
    dataIn.word<= "00000000000010000000000000000000";
    wait for factor*clk_period;
    dataIn.word<= "00000000000010000000000000000000";
    wait for 256*factor*clk_period;
  end process filtering;

  potentialSampling: process
  begin
    potential<= std_logic_vector(dataOut.word);
    wait for clk_period;
  end process potentialSampling;

  freq_divider_test: freq_divider
    generic map(factor=> factor)
    port map(clk=> clk, clk_div=> clk_div, rst=> rst);

  dut: transversalFilter
    generic map(
      order=> order, dataWidth=> dataWidth, weightRom_path=> weightRom_path
      )
    port map(
      clk=> clk, clk_div=> clk_div, dataIn=> dataIn, dataOut=> dataOut
      );

end architecture test;

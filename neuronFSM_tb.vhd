library ieee;
use ieee.std_logic_1164.all;
use work.fixpt_lib.all;

entity neuronFSM_tb is
end neuronFSM_tb;

architecture test of neuronFSM_tb is

  component neuron
  generic(
    numExcSyn, numInhSyn, dataWidth, thr_addrWidth: integer;
    thr_dataPath: string
    );
  port(
    clk, clk_div: in std_logic;
    spike_exc: in std_logic_vector (numExcSyn-1 downto 0);
    spike_inh: in std_logic_vector (numInhSyn-1 downto 0);
    spikeOut: out std_logic:= '0'
    );
  end component neuron;

  constant numExcSyn: integer:= 3;
  constant numInhSyn: integer:= 5;
  constant dataWidth: integer:= 32;
  constant thr_addrWidth: integer:= 9;
  constant thr_dataPath: string:= "./textfiles/threshold.txt";

  signal clk, clk_div: std_logic;
  signal spike_exc: std_logic_vector(numExcSyn-1 downto 0):= "000";
  signal spike_inh: std_logic_vector(numInhSyn-1 downto 0):= "00000";
  signal spikeOut: std_logic;

  component freq_divider
    generic(factor: integer);
    port(
      clk, rst: in std_logic;
      clk_div: out std_logic
      );
  end component;

  constant factor: integer:= 5*numInhSyn;
  signal rst: std_logic;

  constant clk_period: time:= 10 ns;

begin

  clk_gen: process
  begin
    clk<= '1';
    wait for clk_period/2;
    clk<= '0';
    wait for clk_period/2;
  end process clk_gen;

  freq_divider_test: freq_divider
    generic map(factor=> factor)
    port map(clk=> clk, clk_div=> clk_div, rst=> rst);

  neuron_test: neuron
    generic map(numExcSyn=> numExcSyn, numInhSyn=> numInhSyn,
                dataWidth=> dataWidth, thr_addrWidth=> thr_addrWidth,
                thr_dataPath=> thr_dataPath)
    port map(clk=> clk, clk_div=> clk_div, spike_exc=> spike_exc,
             spike_inh=> spike_inh, spikeOut=> spikeOut);

end architecture test;


  

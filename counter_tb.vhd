library ieee;
use ieee.std_logic_1164.all;

entity counter_tb is
end counter_tb;

architecture test of counter_tb is
  component counter
    generic(width: integer);
    port(
      dataIn: in std_logic_vector (width-1 downto 0);
      clk, rst, dataEn: in std_logic;
      rco: out std_logic_vector (0 downto 0);
      dout: out std_logic_vector (width-1 downto 0)
      );
  end component;
  constant clk_period: time:= 10 ns;
  constant width: integer:= 4; -- modify this value appropriately for further
                               -- testing 
  signal clk, rst, dataEn: std_logic;
  signal rco: std_logic_vector (0 downto 0);
  signal dout, dataIn: std_logic_vector(width-1 downto 0);
begin
  clk_gen: process
  begin
    clk<= '0';
    wait for clk_period/2;
    clk<= '1';
    wait for clk_period/2;
  end process clk_gen;
  count_test: process 
  begin
    dataEn<= '0'; -- initially we don't use the data input
    rst<= '1';
    wait for clk_period;
    rst<= '0';
    wait for (2**width-1)*20 ns; -- firstly we test the ability of the counter
                                 -- to output its largest number indefinitely
    rst<= '1'; 
    wait for clk_period;
    rst<= '0';
    wait for (2**width-1)*20 ns;
    dataEn<= '1'; -- now we want to count starting from 2, therefore the first
                  -- number produce should be 3
    dataIn<= "0010";
    wait for clk_period;
    dataEn<= '0';
    datain<= "1111"; -- now we test the ability of the counter to raise the
                     -- overflow flag id dataIn is exactly 2**width 
    wait for 3*clk_period;
    dataEn<= '1';
    wait for clk_period;
    dataEn<= '0';
    wait for 2*clk_period;
    rst<= '1'; -- finally we test the reset signal midway through the counting
               -- process initiated by dataEn
    wait for clk_period;
    rst<= '0';
  end process count_test;
  dut: counter
    generic map(width=> width)
    port map(
      clk=> clk, rst=> rst, dataEn=> dataEn, dataIn=> dataIn, dout=> dout,
      rco=>rco 
      );
end architecture test;

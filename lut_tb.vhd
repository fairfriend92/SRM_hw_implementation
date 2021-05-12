library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

entity lut_tb is
end lut_tb;

architecture test of lut_tb is
  component lut
    generic(
      addr_width, data_width: integer;
      data_path: string
      );
    port(
      clk: in std_logic;
      addr: in std_logic_vector (addr_width-1 downto 0);
      data: out std_logic_vector (data_width-1 downto 0)
      );
  end component;
  constant clk_period: time:= 10 ns;
  constant addr_width: integer:= 2; -- if the width of either addr or data are
                                    -- changed then the test file must be
                                    -- updated appropriately
  constant data_width: integer:= 4;
  -- the following is the path to the test file used to initiate the rom
  constant data_path: string:= "./textfiles/rom.txt";
  signal clk: std_logic;
  signal addr: std_logic_vector (addr_width-1 downto 0);
  signal data: std_logic_vector (data_width-1 downto 0);
begin
  clk_gen: process
  begin
    clk<= '1';
    wait for clk_period/2;
    clk<= '0';
    wait for clk_period/2;
  end process clk_gen;
  -- the testbench merely consists in looping through the values of the lut,
  -- initiated with the numbers stored in the test file. 
  lut_test: process
    variable index: integer;    
  begin
    index:= 0;
    while index/= 2**addr_width loop -- in this loop we generate the addresses
                                     -- used to access the lut
      addr<= std_logic_vector(to_unsigned(index, addr_width));
      index:=index+1;
      wait for clk_period;   
    end loop;
  end process lut_test;
  dut: lut
    generic map(
      addr_width=> addr_width, data_width=> data_width, data_path=> data_path
      )
    port map(
      clk=> clk, addr=> addr, data=> data
      );
end architecture test;

                              
    
  
                                

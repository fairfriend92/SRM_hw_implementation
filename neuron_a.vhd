library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ***
-- this is a special counter: in case of overflow the counter is not reset,
-- instead it outputs the same number untill it receives a reset signal 
-- ***

entity counter is
  generic(width: integer);
  port(
    clk, rst: in std_logic;
    rco: out std_logic_vector (0 downto 0); -- rco stands for ripple carry out
                                            -- the type is vector to allow
                                            -- conversion from unsigned
    dout: out std_logic_vector (width-1 downto 0)
    );
end counter;

architecture behavioural of counter is
  signal rco_int: unsigned (0 downto 0):= "0"; 
  signal dout_int: unsigned (width-1 downto 0):= (others=> '0');
  -- these are internal signals used to do arithmetic
begin
  count: process(clk, rst)
  begin
    if(clk'event and clk= '1') then
      if(rst= '1') then -- if the chip is reset so is its output
        dout_int<= (others => '0');
        rco_int<= "0";
      elsif(rst= '0') then 
        if(rco_int= "0") then -- the chip counts upward only if the overflow
                              -- condition has not been met 
          dout_int<= dout_int + 1;
          if(dout_int= 2**width - 2) then -- test the overflow condition
            rco_int<= "1";
          end if;
        else dout_int<= dout_int; -- counting stops in case of overflow
        end if;
      end if;
    end if;
  end process count;
  dout<= std_logic_vector(dout_int);
  rco<= std_logic_vector(rco_int);
end architecture behavioural;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

-- ***
-- the following is a rudimentary lookup table (lut)
-- *** 

entity lut_a is
  generic(
    addr_width, data_width: integer;
    data_path: string -- among the generics we include the location of the file
                      -- used to initalize the rom
    );
  port(
    clk: in std_logic;
    addr: in std_logic_vector (addr_width-1 downto 0);
    data: out std_logic_vector (data_width-1 downto 0)
    );
end lut_a;

architecture behavioural of lut_a is
  subtype word is std_logic_vector (data_width-1 downto 0);
  type rom_type is array (integer range 0 to 2**addr_width-1) of word;
  file data_file: text is data_path;  -- this is the file used to initialize
                                      -- the rom
  signal rom: rom_type; 
begin
  -- in the following process we initialize the rom from a file. Since we can't
  -- read a file of std_logic_vectors firstly we read a file of ASCII
  -- characters, then we convert the strings in std_logic_vectors
  rom_init: process(clk)
  variable data_line: line;
  variable data_string: string (data_width-1 downto 0);
  variable i, j: integer;
  variable tmp: word; -- used to hold the vector while it's being translated
                      -- from a string before it's passed to the rom
  begin
    j:= 0;
    while not endfile(data_file) loop
      i:= 0;
      readline(data_file, data_line); -- here we read the line...
      read(data_line, data_string); -- ...and here we store it in a string
      while i< data_width loop -- in this loop we do the conversion for the i-th
                               -- character of the j-th string
        case data_string(i) is
          when '0'=> tmp(i):= '0';
          when '1'=> tmp(i):= '1';
          when others=> tmp(i):= '-';                          
        end case;
         i:= i+1;        
      end loop;
      rom(j)<= tmp; -- we finally pass the vector to its rom location
      j:= j+1;
    end loop;
  end process rom_init;
  -- in the following process we serve the request of the stimulus
  -- according to the address provided
  addr_decod: process(clk)
  begin
    if(clk'event and clk= '1') then
      data<= rom(to_integer(unsigned(addr)));
    end if;
  end process addr_decod;
end architecture behavioural;



    


       
      
  

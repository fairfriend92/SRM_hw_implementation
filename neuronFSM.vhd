library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.fixpt_lib.all;

entity neuron is
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
end neuron;

architecture behavioural of neuron is

  component counter
    generic(width: integer);
    port(
      dataIn: in std_logic_vector (width-1 downto 0);
      clk, rst, dataEn: in std_logic;
      rco: out std_logic_vector (0 downto 0);
      dout: out std_logic_vector (width-1 downto 0)
      );
  end component counter;

  constant width: integer:= thr_addrWidth; -- this is the lenght of the address
  -- used to access the lut containing the values of the dynamic threshold
  signal counterDataIn: std_logic_vector (width-1 downto 0):= (others=> '1');
  signal rst: std_logic:= '0';
  signal dataEn: std_logic:= '1';
  signal counter_to_lut: std_logic_vector(width-1 downto 0);

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
  end component lut;

  constant data_width: integer:= dataWidth;
  constant addr_width: integer:= thr_addrWidth;
  constant data_path: string:= thr_dataPath;
  signal threshold: std_logic_vector (data_width-1 downto 0);
  
  component clusterSyn
    generic(numSyn, addrWidth: integer; dataPath_lut: string);
    port(
      clk, clk_div: in std_logic;
      spike: in std_logic_vector (numSyn-1 downto 0);
      current: out fixpt_word:= (scale=> 17, word=> (others=> '0'))
      );
  end component;

  constant numSyn_exc: integer:= numExcSyn;
  constant numSyn_inh: integer:= numInhSyn;
  constant addrWidth_exc: integer:= 6;
  constant addrWidth_inh: integer:= 7;
  constant dataPath_exc: string:= "./textfiles/excSyn.txt";
  constant dataPath_inh: string:= "./textfiles/inhSyn.txt";

  signal current_exc, current_inh: fixpt_word:=
    (scale=> 17, word=> (others=> '0'));

  component transversalFilter
    generic(order, dataWidth: integer; weightRom_path: string);
    port(
      clk, clk_div, enable: in std_logic;
      dataIn: in fixpt_word:= (scale=> 17, word=> (others=> '0'));
      dataOut: out fixpt_word:= (scale=> 17, word=> (others=> '0'))
      );
  end component;

  constant order: integer:= 256;
  constant weightRom_path: string:= "./textfiles/filter.txt";
  signal dataOut: fixpt_word:= (scale=> 17, word=> (others=> '0'));
  signal filterEnable: std_logic:= '1';

  file data_file: text is "./textfiles/current_ext.txt";
  signal dataIn: fixpt_word:= (scale=> 17, word=> (others=> '0'));
  signal potGreaterThanThr, afterPotential_flag, spike_flag,
    tmpRst, rstSent, thresholdRst: std_logic:= '0';
  
begin

  clockCheck: process(clk_div)
  begin
    if(rising_edge(clk_div)) then spike_flag<= '1';
    elsif(falling_edge(clk_div)) then spike_flag<= '0'; end if;
  end process clockCheck;

  thresholdRest: process(clk_div)

    -- the dynamic threshold needs to be reset everytime the neuron emits a new
    -- spike. Therefore, when this happens, we must send a reset signal to the
    -- counter which generates the addresses used to access the lut containing
    -- the values of the dynamic threshold
 
    begin
    
      if(rising_edge(clk_div)) then
        if(rstSent= '0' and rst/= tmpRst and afterPotential_flag= '0') then
          -- the reset signal is sent only when a new spike has been emitted,
          -- that is to say when the neuron enters the after potential phase.
          -- In addition to that we must ensure that the signal is sent only
          -- once: to this purpose we check the flag rstSent. tmpRst is the
          -- signal which "stores" the reset value untill we can pass it to the
          -- counter at the next rising edge of clk_div
          dataEn<= tmpRst;
          counterDataIn<= (others=> '0');
          rstSent<= '1';
        else
          dataEn<= '0';
          rstSent<= '0';
        end if;                   
      end if;

    end process;  
      
  spike_emission: process(clk)

    variable refractoryPeriod: integer:= 0;
    variable endCycle: std_logic:= '0';

  begin

    if(clk'event and clk= '1') then
      if(spike_flag= '1') then
        if(potGreaterThanThr= '1' and refractoryPeriod= 0
           and endCycle= '0') then
          -- since we use clk to update the process but we actually want to
          -- decrease the refractory period every new clk_div we test endCycle,
          -- whose value is reset everytime clk_div is low
          spikeOut<= '1';
          afterPotential_flag<= '1'; -- when the neuron emits a spike it enters
                                     -- the after potential phase
          filterEnable<= '0'; -- filtering is disable while the neuron is in
                              -- the after potential state since it shouldn't
                              -- be susceptible to stimulation
          refractoryPeriod:= 22; 
          tmpRst<= '1';
        elsif(refractoryPeriod/= 0 and endCycle= '0') then
          refractoryPeriod:= refractoryPeriod - 1;
          -- the following ifs account for the delays accumulated by the signals
          -- which are sent to the components: we send the signals before they
          -- are actually needed to prevent the delay
          if(refractoryPeriod= 3) then afterPotential_flag<= '0'; end if;
          if(refractoryPeriod= 1) then filterEnable<= '1'; end if; 
        end if;
        endCycle:= '1';
      else
        if(rstSent= '1') then
          tmpRst<= '0'; end if;
        spikeOut<= '0';
        endCycle:= '0';
      end if;
    end if;

  end process spike_emission;
  
  threshold_comparison: process(clk)

    variable rest_potential: fixpt_word:=
      (scale=> 17, word=> "11111111011111111111111111111111");
    variable total_potential: fixpt_word:= (scale=> 17, word=> (others=> '0'));
    variable thresholdTmp: fixpt_word:= (scale=> 17, word=> (others=> '0'));
    
  begin

    if(clk'event and clk= '1') then
      if(spike_flag= '1') then
        total_potential:= sum_words(rest_potential, dataOut);
        thresholdTmp.word:= signed(threshold);
        potGreaterThanThr<= greaterThan(total_potential, thresholdTmp);
      end if;
    end if;

  end process threshold_comparison;

  stimulus_processing: process(clk)

    variable current_exc_tmp, current_inh_tmp, current_ext, total_current,
      synapsesCurrent, synapsesCurrent_tmp: fixpt_word:=
      (scale=> 17, word=> (others=> '0'));
    -- weight_exc and weight_inh are the conversion factors for the currents
    -- produced by the synapses
    variable weight_exc: fixpt_word:=
      (scale=> 17, word=> ("00000000000000000011001100110011"));
    variable weight_inh: fixpt_word:=
      (scale=> 17, word=> ("00000000000000000001000011100101"));
    -- if we expressed the weights in pico ampere the chosen precision would not
    -- be sufficient; instead we multiply the resulting current by the
    -- following factor
    variable fromNanoToPico: fixpt_word:=
      (scale=> 17, word=> ("00000000000000000000000010000000"));       

    variable data_line: line;
    variable data_string: string (dataWidth-1 downto 0);
    variable i: integer:= 0;
    variable tmp: signed (dataWidth-1 downto 0);
    variable done_flag: std_logic:= '0';

  begin

    -- firstly we read from a txt file the eventual external current. We do so
    -- at every new clk_div untill the file ends

    if(clk'event and clk= '1') then
      if(spike_flag= '1' and done_flag= '0') then 
        if not endfile(data_file) then
          i:= 0;
          readline(data_file, data_line);
          read(data_line, data_string);
          while i< dataWidth loop
            case data_string(i) is
              when '0'=> tmp(i):= '0';
              when '1'=> tmp(i):= '1';
              when others=> tmp(i):= '-';                          
            end case;
            i:= i+1;
          end loop;
          current_ext.word:= tmp;
          done_flag:= '1';
        else assert (false) report "no more external input to read:" & CR & LF &
               "make sure the simulation ends before this happens"
               severity failure;                        
        end if;            
      elsif(spike_flag= '0') then done_flag:= '0';
      end if;

      -- here we sum the currents of the synapses by the respective weights.
      -- Then we sum the aforementioned currents with the external current and
      -- we pass the result to the membrane filter
      
      current_exc_tmp:= prod_words(current_exc, weight_exc);
      current_inh_tmp:= prod_words(current_inh, weight_inh);
      synapsesCurrent:= sum_words(current_exc_tmp, current_inh_tmp);
      synapsesCurrent_tmp:= prod_words(synapsesCurrent, fromNanoToPico);
      total_current:= sum_words(synapsesCurrent_tmp, current_ext);
      dataIn<= total_current;

    end if;

  end process stimulus_processing;

  addressGenerator: counter
    generic map(width=> width)
    port map(dataIn=> counterDataIn, dataEn=> dataEn, rst=> rst, clk=> clk_div,
             dout=> counter_to_lut);

  dynamicThreshold: lut
    generic map(addr_width=> addr_width, data_width=> data_width,
                data_path=> data_path)
    port map(clk=> clk_div, addr=> counter_to_lut, data=> threshold);

  clusterSyn_exc: clusterSyn
    generic map(numSyn=> numSyn_exc, addrWidth=> addrWidth_exc,
                dataPath_lut=> dataPath_exc)
    port map(clk=> clk, clk_div=> clk_div, spike=> spike_exc,
             current=> current_exc);

  clusterSyn_inh: clusterSyn
    generic map(numSyn=> numSyn_inh, addrWidth=> addrWidth_inh,
                dataPath_lut=> dataPath_inh)
    port map(clk=> clk, clk_div=> clk_div, spike=> spike_inh,
             current=> current_inh);

  transversal_filter: transversalFilter
    generic map(order=> order, dataWidth=> dataWidth,
                weightRom_path=> weightRom_path)
    port map(clk=> clk, clk_div=> clk_div, dataIn=> dataIn, dataOut=> dataOut,
             enable=> filterEnable);

end architecture behavioural;

           


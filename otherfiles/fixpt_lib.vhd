library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ***
-- This is a very basic package to do fixed point arithmetic. Herein is defined
-- a record, fixpt_word, which holds the integer value and the scaling factor.
-- In addition to that we define the functions necessary to sum, to multiply
-- and to compare two numbers.
--
-- Operations between numbers of different length or scaling factor are not
-- valid and cause the simulation to fail. Overflow is noted but
-- doesn't cause the simulation to halt. 
-- ***

package fixpt_lib is 

  type fixpt_word is
  record
    scale: integer; -- the scaling factor is, more appropriately, the number of
                    -- fractional digits
    word: signed (32-1 downto 0); 
  end record;

  function sum_words (a, b: fixpt_word) return fixpt_word;
  function prod_words (a, b: fixpt_word) return fixpt_word;
  function greaterThan (a, b: fixpt_word) return std_logic;
      
end package fixpt_lib;

package body fixpt_lib is

  function sum_words (a, b: fixpt_word) return fixpt_word is
    variable result: fixpt_word;
    variable tmp, tmp_a, tmp_b: signed (32 downto 0):= (others=> '0');
  begin
    assert (a.scale= b.scale) report
      "The two words have different scale factors" severity failure;
    result.scale:= a.scale;
    tmp_a:= a.word(32-1) & a.word; -- sign extension
    tmp_b:= b.word(32-1) & b.word;
    tmp:= tmp_a + tmp_b;
    assert (tmp(32)= tmp(32-1)) report "sum_words: OVERFLOW" severity warning;
    result.word:= tmp(32-1 downto 0);
    return result;    
  end sum_words;

  function prod_words (a, b: fixpt_word) return fixpt_word is
    variable result: fixpt_word;
    variable tmp_result: signed (64-1 downto 0):= (others=> '0');
    variable index: integer;
    variable break_flag: std_logic:= '0';
  begin
    assert (a.scale= b.scale) report
      "The two words have different scale factor" severity failure;
    result.scale:= a.scale;
    tmp_result:= a.word * b.word;
    index:= 32+result.scale;
    while(index< 64-1 and break_flag= '0') loop
      if(tmp_result(index)/= tmp_result(32-1+result.scale)) then
        assert (false) report "prod_words: OVERFLOW" severity warning;
        break_flag:= '1'; 
      end if;
      index:= index+1;
    end loop;
    result.word:= tmp_result(32-1+result.scale downto result.scale); -- we want
    -- the scale of the result to be that of the operand, therefore we must
    -- diregard the last result.scale fractional digits 
    return result;              
  end prod_words;

  -- the function greaterThan returns '1' is the first operand, 'a' in the
  -- following, is greater than the second one. 
  
  function greaterThan (a, b: fixpt_word) return std_logic is
    variable index: integer:= 0;
    variable result, endComputation: std_logic:= '0';
  begin
    assert (a.scale= b.scale) report
      "The two words have different scale factors" severity failure;
    -- firstly we check whether we can shorten the computation by merely
    -- looking at the signs of the two numbers. 
    if (a.word(31)= '0' and b.word(31)= '1') then
      result:= '1'; endComputation:= '1';
    elsif(a.word(31)= '1' and b.word(31)= '0') then
      result:= '0'; endComputation:= '1';
    elsif(a.word(31)/= b.word(31)) then endComputation:= '0';
    end if;
    -- if we cannot determine which number is bigger by looking at the signs we
    -- proceed in the computation
    if(endComputation= '0') then
      while(index< 31) loop
        if(a.word(index)= '1' and b.word(index)= '0') then result:= '1';
        elsif(a.word(index)= '0' and b.word(index)= '1') then result:= '0';
        end if;
        index:= index+1;
      end loop;
    end if;
    return result;
  end greaterThan;
   
end package body;


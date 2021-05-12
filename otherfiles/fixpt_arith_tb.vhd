library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixpt_lib.all;

entity fixpt_arith_tb is
end fixpt_arith_tb;

architecture test of fixpt_arith_tb is
begin
  arith_test: process
    variable a, b, c: fixpt_word;
    variable int_part: integer;
  begin

    a.scale:= 19;
    b.scale:= a.scale;
    
    -- firstly we test a simple summation 

    a.word:= "00000000000011110101111101100100";
    b.word:= "00000000000011101100010100010101";
    c:= sum_words(a, b);
    int_part:= to_integer(c.word(32-1 downto 0));
    report "fixpt_arith_tb: the first operand of the sum is " &
      integer'image(to_integer(a.word));
    report "fixpt_arith_tb: the second operand of the sum is " &
      integer'image(to_integer(b.word));
    report "fixpt_arith_tb: the result of the sum is "
      & integer'image(int_part);

    -- then we test a subtraction

    a.word:= "00000000000011110101111101100100";
    b.word:= "10000000000011101100010100010101";
    c:= sum_words(a, b);
    int_part:= to_integer(c.word(32-1 downto 0));
    report "fixpt_arith_tb: the first operand of the sum is " &
      integer'image(to_integer(a.word));
    report "fixpt_arith_tb: the second operand of the sum is " &
      integer'image(to_integer(b.word));
    report "fixpt_arith_tb: the result of the difference is "
      & integer'image(int_part);

    -- finally we verify that the overflow condition is properly asserted

    a.word:= "01111111111111111111111111111111";
    b.word:= "01111111111111111111111111111111";
    c:= sum_words(a, b);

    -- onto the multiplication function:
    -- firstly we test a simple product of two numbers with positive sign

    a.word:= "00000000000011110101111101100100";
    b.word:= "00000000000000000000100000000010";
    c:= prod_words(a, b);
    int_part:= to_integer(c.word(32-1 downto 0));
    report "fixpt_arith_tb: the first operand of the product is " &
      integer'image(to_integer(a.word));
    report "fixpt_arith_tb: the second operand of the product is " &
      integer'image(to_integer(b.word));
    report "fixpt_arith_tb: the result of the product (both + sign) is "
      & integer'image(int_part); -- in order to obtain the result in binary
    -- the integer should be converted first; then the binary number should be
    -- padded with leading zeros, untill we get a word with 32 bits. Finally
    -- the decimal mark should be added after the first 12 bits

    -- secondly we test the product of two numbers with negative sign

    a.word:= "11111111111100001010000010011011";
    b.word:= "11111111111111111111011111111110";
    c:= prod_words(a, b);
    int_part:= to_integer(c.word(32-1 downto 0));
    report "fixpt_arith_tb: the first operand of the product is " &
      integer'image(to_integer(a.word));
    report "fixpt_arith_tb: the second operand of the product is " &
      integer'image(to_integer(b.word));
    report "fixpt_arith_tb: the result of the product (both - sign) is "
      & integer'image(int_part);

    -- then we test the product of two numbers with different signs

    a.word:= "00000000000011110101111101100100";
    b.word:= "11111111111111111111011111111110";
    c:= prod_words(a, b);
    int_part:= to_integer(c.word(32-1 downto 0));
    report "fixpt_arith_tb: the first operand of the product is " &
      integer'image(to_integer(a.word));
    report "fixpt_arith_tb: the second operand of the product is " &
      integer'image(to_integer(b.word));
    report "fixpt_arith_tb: the result of the product (different signs) is "
      & integer'image(int_part);

    -- we test the overflow for the sum of negative numbers

    a.word:= "10000000000000000000000000000000";
    b.word:= "10000000000000000000000000000000";
    c:= sum_words(a, b);

    -- we test the overflow for the prod of positive numbers

    a.word:= "01111111111110110111110111111111";
    b.word:= "00111011101111111111111111111111";
    c:= prod_words(a, b);

    -- we test the overflow for the prod of negative numbers

    a.word:= "10000000000000111000000000000000";
    b.word:= "10000000000100001110000100010000";
    c:= prod_words(a, b);
   
    wait;
  end process arith_test;
end architecture test;


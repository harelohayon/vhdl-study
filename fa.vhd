library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity fa is
  port (
    a    : in  std_logic;
    b    : in  std_logic;
    cin  : in  std_logic;
    cout : out std_logic;
    s    : out std_logic
  );
end fa;

architecture a of fa is
begin
  s    <= (a xor b) xor cin;
  cout <= (a and b) or (a and cin) or (b and cin);
end a;
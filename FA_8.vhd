library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity FA_8 is
  port (
    a    : in  std_logic_vector(7 downto 0);
    b    : in  std_logic_vector(7 downto 0);
    s    : out std_logic_vector(7 downto 0);
    cout : out std_logic
  );
end FA_8;

architecture a of FA_8 is
signal c : std_logic_vector(8 downto 0);
  component fa
    port (
      a    : in  std_logic;
      b    : in  std_logic;
      cin  : in  std_logic;
      s    : out std_logic;
      cout : out std_logic
    );
  end component;
  
begin
  c(0) <= '0'; 
  cout <= c(7); 
  gen_adders: for i in 0 to 7 generate
    adder: fa
      port map (
        a    => a(i),
        b    => b(i),
        cin  => c(i),
        s    => s(i),
        cout => c(i+1)
      );
  end generate;
end architecture a;

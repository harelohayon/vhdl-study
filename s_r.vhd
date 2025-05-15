entity s_r is
  port ( s, r : in bit;
    q, p : out bit);
end ;

architecture arc_sff of s_r is
  signal nq, np: bit;
begin
  nq <= r nor np;
  np <= s nor nq;
  
  q <= nq;
  p <= np;
end arc_sff;
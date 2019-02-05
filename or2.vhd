LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity OR2 is
port (
      in0    : in  STD_LOGIC;
      in1    : in  STD_LOGIC;
      output : out STD_LOGIC -- in0 and in1
);
end OR2;

ARCHITECTURE behave OF OR2 IS
begin 
    output <= in0 OR in1;
end behave;
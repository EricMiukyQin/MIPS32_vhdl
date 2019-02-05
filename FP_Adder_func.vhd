library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- FP Adder (32-bit: 1 bit sign, 8 bits exponent, 23 bits mantissa)

package FP_Adder_Func is    
   function fadd (x : std_logic_vector(31 downto 0); y : std_logic_vector(31 downto 0)) return STD_LOGIC_VECTOR;        
end FP_Adder_Func;

package BODY FP_Adder_Func is
   function fadd (x : std_logic_vector(31 downto 0); y : std_logic_vector(31 downto 0)) return STD_LOGIC_VECTOR is 
                  variable z : std_logic_vector (32 downto 0);
   variable m1,m2   :  std_logic_vector (47 downto 0);   -- mantissa of 'x' and 'y' including implicit '1' 
   variable tempm   :  std_logic_vector (47 downto 0);   -- temporary mantissa   
   variable tempm2  :  std_logic_vector (93 downto 0);   -- temporary final mantissa   
   variable m       :  std_logic_vector(22 downto 0);    -- mantissa result   
   variable e       :  std_logic_vector (7 downto 0);    -- exponent result
   variable e1,e2   :  std_logic_vector(8 downto 0);     -- temporary exponents 
   variable tempe   :  std_logic_vector(8 downto 0);     -- temporary exponent result
   variable s,xs,ys :  std_logic;	                 -- final sign bit,s and signs as and bs of a and b                      
   variable bias    :  std_logic_vector(8 downto 0);     -- exponent bias
   variable i       :  integer;                          
   variable j       :  integer;
   variable ov      :  std_logic;
begin
   m1     := "0000000000000000000000001" & x(22 downto 0);  
   m2     := "0000000000000000000000001" & y(22 downto 0);
   e1     := '0' & x(30 downto 23);                      -- exponent of x to e1 (extra bit for overflow detection)
   e2     := '0' & y(30 downto 23);                      -- exponent of y to e2
   xs     := x(31);	                                 -- sign of x 	        	         
   ys     := y(31);	                                 -- sign of y	        	         
   ov     := '0';                                        -- set overflow flag to cleared (no overflow, no error)     
   -- clear mantissa and exponent  
   tempm  := "000000000000000000000000000000000000000000000000";
   tempm2 := "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"; 
   tempe  := "000000000";  
   -------------------  add the mantissas  ---------------------
   if e1(8 downto 0) = "000000000" then
      if m1(22 downto 0) = "00000000000000000000000" then
         s := ys;  
         e := e2(7 downto 0);
         m := m2(22 downto 0);
         ov := '0'; 
      else
         s := '0';
         e := "00000000";
         m := "00000000000000000000000";
         ov := '0'; 
      end if;
   elsif e1(8 downto 0) = "011111111" then
      s := '0';
      e := "11111111";
      m := "00000000000000000000000";  
      ov := '1';  -- x error (NAN or infinity)
   else
      if e2(8 downto 0) = "000000000" then
         if m2(22 downto 0) = "00000000000000000000000" then
            s := xs;
            e := e1(7 downto 0);
            m := m1(22 downto 0);
            ov := '0'; 
         else
            s := '0';
            e := "00000000";
            m := "00000000000000000000000";
            ov := '0'; 
         end if;
      elsif e2(8 downto 0) = "011111111" then
         s := '0';
         e := "11111111";
         m := "00000000000000000000000";  
         ov := '1';  -- y error   
      else
         if (e1 = e2 and m1 = m2 ) then
            if xs /= ys then
               s := '0';
               e := "00000000";
               m := "00000000000000000000000";
               ov := '0';         
            else
               tempm := m1 + m2;
               s := xs XOR ys;
               m := tempm(23 downto 1);
               e := e1(7 downto 0);
               e := e + "00000001";
               ov := '0';
            end if;
         else
            if xs = ys then
               if e1 = e2 then      
                  tempm := m1 + m2;
                  s := xs XOR ys;
                  m := tempm(23 downto 1);
                  e := e1(7 downto 0);
                  e := e + "00000001";
                  ov := '0';
               elsif e1 > e2 then
                  s := xs XOR ys;
                  bias := e1 - e2;
                  if bias > "00010111" then
                     e := e1(7 downto 0);
                     m := m1(22 downto 0);
                     ov := '0';  -- y almost zero  
                  else
                     i := 0;
                     loop  -- Shift Mantissa
                        e2 := e2 + "000000001";
                        j := 0;
                        loop
                           m1(46 - j) := m1(45 - j);
                           j := j + 1;
                           exit when j = 46;
                        end loop;
                        m1(0) := '0';
                        i := i + 1;
                        exit when e1 = e2;
                     end loop;
                     tempm := m1 + m2;
                     if tempm( 24 + i ) = '1' then
                        e2 := e2 + "000000001";
                        m := tempm( 23 + i downto i + 1 );
                        e := e2(7 downto 0);
                        ov := '0';
                     else
                        m := tempm( 22 + i downto i );
                        e := e2(7 downto 0);
                        ov := '0';    
                     end if;  
                  end if;
               else
                  s := xs XOR ys;
                  bias := e2 - e1;
                  if bias > "00010111" then
                     e := e2(7 downto 0);
                     m := m2(22 downto 0);
                     ov := '0';  -- x almost zero
                  else
                     i := 0;
                     loop
                        e1 := e1 + "000000001";
                        j := 0;
                        loop  -- Shift Mantissa
                           m2(46 - j) := m2(45 - j);
                           j := j + 1;
                           exit when j = 46;
                        end loop;
                        m2(0) := '0';
                        i := i + 1;
                        exit when e1 = e2;
                     end loop;
                     tempm := m1 + m2;
                     if tempm( 24 + i ) = '1' then
                        e1 := e1 + "000000001";
                        m := tempm( 23 + i downto i + 1 );
                        e := e1(7 downto 0);
                        ov := '0';
                     else
                        m := tempm( 22 + i downto i );
                        e := e1(7 downto 0);
                        ov := '0';    
                     end if;  
                  end if;    
               end if;
            else
               -- xs /= ys
               if e1 > e2 then
                  s := xs;
                  bias := e1 - e2;
                  if bias > "000010111" then
                     e := e1(7 downto 0);
                     m := m1(22 downto 0);
                     ov := '0';  -- y almost zero
                  else
                     i := 0;
                     loop
                        e2 := e2 + "000000001";
                        j := 0;
                        loop  -- Shift Mantissa
                           m1(46 - j) := m1(45 - j);
                           j := j + 1;
                           exit when j = 46;
                        end loop;
                        m1(0) := '0';  
                        i := i + 1;
                        exit when e1 = e2;
                     end loop;
                     tempm := m1 - m2;
                     tempm2( 70 downto 23 ) := tempm( 47 downto 0 );
                     j := 0;
                     e1 :=  e1 + "000000001";
                     loop  -- Shift Mantissa
                        m := tempm2( 45 + i - j downto 23 + i - j );
                        j := j + 1;
                        e1 :=  e1 - "000000001"; 
                        exit when tempm2( 47 + i - j ) = '1';
                     end loop;
                     e := e1(7 downto 0);
                     ov := '0';
                  end if;    
               elsif e1 < e2 then
                  s := ys;
                  bias := e2 - e1;
                  if bias > "000010111" then
                     e := e1(7 downto 0);
                     m := m2(22 downto 0);
                     ov := '0';  -- x almost zero
                  else
                     i := 0;
                     loop  -- Shift Mantissa
                        e1 := e1 + "000000001";
                        j := 0;
                        loop
                           m2(46 - j) := m2(45 - j);
                           j := j + 1;
                           exit when j = 46;
                        end loop;
                        m2(0) := '0';  
                        i := i + 1;
                        exit when e1 = e2;
                     end loop;                      
                     tempm := m2 - m1;
                     tempm2( 70 downto 23 ) := tempm( 47 downto 0 );
                     j := 0;
                     e2 :=  e2 + "000000001";
                     loop  -- Shift Mantissa
                        m := tempm2( 45 + i - j downto 23 + i - j );
                        j := j + 1;
                        e2 :=  e2 - "000000001"; 
                        exit when tempm2( 47 + i - j ) = '1';
                     end loop;
                     e := e2(7 downto 0);
                     ov := '0';
                  end if;
               else
                  -- e1 = e2
                  -- m1 /= m2
                  if m1 > m2 then
                     s := xs;
                     tempm := m1 - m2;
                     e := e1( 7 downto 0 );
                     m := tempm(22 downto 0);
                     ov := '0';
                  elsif m1 < m2 then
                     s := ys;         
                     tempm := m2 - m1;
                     e := e2( 7 downto 0 );
                     m := tempm(22 downto 0);
                     ov := '0';
                  else 
                     s := '0';
                     tempm := "000000000000000000000000000000000000000000000000";
                     e := "00000000";
                     m := tempm(22 downto 0);
                     ov := '0';
                  end if;
               end if;   
            end if;
         end if;  
      end if;
   end if;        
   z := ov & s & e & m;
   return z;
end fadd;
end FP_Adder_Func;

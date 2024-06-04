-- Stage 3 of the 4-stage pipelined design
-- Takes in the decoded instruction from the register module (stage 2)
-- and performs the necessary operations on the register values to
-- compute the output value for the given instruction. The values of
-- registers rs1, rs2, rs3 are read in from the register module unless
-- one of their addresses matches the address of a register currently in
-- the write back stage. If that is the case, data forwarding occurs and
-- the new value from write back is read in from the forwarding unit.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multimedia_alu is
	port (										   
		rs1 : in std_logic_vector (127 downto 0);
		rs2 : in std_logic_vector (127 downto 0);
		rs3 : in std_logic_vector (127 downto 0);
		opcode : in std_logic_vector (7 downto 0); 
		load_index : in std_logic_vector (2 downto 0);
		imm : in std_logic_vector (15 downto 0);
		instr : in std_logic_vector (1 downto 0);	 
		rd : out std_logic_vector (127 downto 0)
	);					  
end multimedia_alu;		


architecture alu of multimedia_alu is	

constant int_max : integer := 2147483647; -- maximum value of a 32-bit signed integer
constant int_min : integer := -2147483648; -- minimum value of a 32-bit signed integer
-- maximum and minimum values of a 64-bit signed long integer
constant long_max : unsigned(63 downto 0) := "0111111111111111111111111111111111111111111111111111111111111111";  
constant long_min : unsigned(63 downto 0) := "1000000000000000000000000000000000000000000000000000000000000000";

-- Signed Integer Multiply-Add Low with Saturation: Multiply low 16-bit-fields of each 32-bit field of registers rs3 and rs2, 
-- then add 32-bit products to 32-bit fields of register rs1, and save result in register rd
function SignedIntegerMultiplyAddLowWithSaturation(
    rs1 : in std_logic_vector(127 downto 0);
    rs2 : in std_logic_vector(127 downto 0);
    rs3 : in std_logic_vector(127 downto 0)
) return std_logic_vector is
variable result : signed(31 downto 0);
variable unsigned_result : unsigned(32 downto 0);
    variable rd_temp : std_logic_vector(127 downto 0);
begin	   
    for i in 0 to 3 loop 	  
		-- if product of 16-bit fields of rs3 and rs2 is positive and the 32-bit field of rs1 is positive
		if ((signed((signed(rs3(32*i + 15 downto 32*i)) * signed(rs2(32*i + 15 downto 32*i)))) > 0) and signed(rs1(32*i + 31 downto 32*i)) > 0) then
			unsigned_result(32) := '0';
			unsigned_result(31 downto 0) := (unsigned(rs3(32*i + 15 downto 32*i)) * unsigned(rs2(32*i + 15 downto 32*i))) + unsigned(rs1(32*i + 31 downto 32*i));	 
			
			if unsigned_result > to_unsigned(int_max, 33) then
            	result := to_signed(int_max, 32);
			else
				result := (signed(rs3(32*i + 15 downto 32*i)) * signed(rs2(32*i + 15 downto 32*i))) + signed(rs1(32*i + 31 downto 32*i));
        	end if;	
																																	
		-- if product of 16-bit fields of rs3 and rs2 is negative and the 32-bit field of rs1 is negative	
		elsif ((signed((signed(rs3(32*i + 15 downto 32*i)) * signed(rs2(32*i + 15 downto 32*i)))) < 0 and signed(rs1(32*i + 31 downto 32*i)) < 0)) then
			unsigned_result := unsigned(signed(signed(rs3(32*i + 15 downto 32*i)) * signed(rs2(32*i + 15 downto 32*i)))) + unsigned(rs1(32*i + 31 downto 32*i));	 
			if signed(unsigned_result) < to_signed(int_min, 33) then
            	result := to_signed(int_min, 32);
			else
				result := signed(signed((signed(rs3(32*i + 15 downto 32*i)) * signed(rs2(32*i + 15 downto 32*i))))
				+ signed(rs1(32*i + 31 downto 32*i)));
			end if;
			
		else
			result := signed(signed((signed(rs3(32*i + 15 downto 32*i)) * signed(rs2(32*i + 15 downto 32*i))))
            + signed(rs1(32*i + 31 downto 32*i)));

        	if result > to_signed(int_max, 32) then
            	result := to_signed(int_max, 32);
        	elsif result < to_signed(int_min, 32) then
            	result := to_signed(int_min, 32);
        	end if;	
        end if;
			
        rd_temp(32*i + 31 downto 32*i) := std_logic_vector(result);
    end loop;
    return rd_temp;
end function; 

-- Signed Integer Multiply-Add High with Saturation: Multiply high 16-bit-fields of each 32-bit field of registers rs3 and rs2, 
-- then add 32-bit products to 32-bit fields of register rs1, and save result in register rd
function SignedIntegerMultiplyAddHighWithSaturation(
    rs1 : in std_logic_vector(127 downto 0);
    rs2 : in std_logic_vector(127 downto 0);
    rs3 : in std_logic_vector(127 downto 0)
) return std_logic_vector is
variable result : signed(31 downto 0);
variable unsigned_result : unsigned(32 downto 0);
    variable rd_temp : std_logic_vector(127 downto 0);
begin
    for i in 0 to 3 loop					
		-- if product of 16-bit fields of rs3 and rs2 is positive and the 32-bit field of rs1 is positive
        if ((signed((signed(rs3(32*i + 31 downto 32*i + 16)) * signed(rs2(32*i + 31 downto 32*i + 16)))) > 0) and signed(rs1(32*i + 31 downto 32*i)) > 0) then
			unsigned_result(32) := '0';
			unsigned_result(31 downto 0) := unsigned(unsigned((unsigned(rs3(32*i + 31 downto 32*i + 16)) * unsigned(rs2(32*i + 31 downto 32*i + 16))))
            + unsigned(rs1(32*i + 31 downto 32*i)));	
			
			if unsigned_result > to_unsigned(int_max, 33) then
            	result := to_signed(int_max, 32);
			else
				result := signed(signed((signed(rs3(32*i + 31 downto 32*i + 16)) * signed(rs2(32*i + 31 downto 32*i + 16))))
            		+ signed(rs1(32*i + 31 downto 32*i)));
        	end if;							  
			
		-- if product of 16-bit fields of rs3 and rs2 is negative and the 32-bit field of rs1 is negative	
		elsif ((signed((signed(rs3(32*i + 31 downto 32*i + 16)) * signed(rs2(32*i + 31 downto 32*i + 16)))) < 0 and signed(rs1(32*i + 31 downto 32*i)) < 0)) then
			unsigned_result := unsigned(signed(signed(rs3(32*i + 31 downto 32*i + 16)) * signed(rs2(32*i + 31 downto 32*i + 16)))) + unsigned(rs1(32*i + 31 downto 32*i));	 
			if signed(unsigned_result) < to_signed(int_min, 33) then
            	result := to_signed(int_min, 32);
			else
				result := signed(signed((signed(rs3(32*i + 31 downto 32*i + 16)) * signed(rs2(32*i + 31 downto 32*i + 16))))
				+ signed(rs1(32*i + 31 downto 32*i)));
			end if;
			
		else
			result := (signed(rs3(32*i + 31 downto 32*i + 16)) * signed(rs2(32*i + 31 downto 32*i + 16)) + signed(rs1(32*i + 31 downto 32*i)));

        	if result > to_signed(int_max, 32) then
            	result := to_signed(int_max, 32);
        	elsif result < to_signed(int_min, 32) then
            	result := to_signed(int_min, 32);
        	end if;	
        end if;
			
        rd_temp(32*i + 31 downto 32*i) := std_logic_vector(result);
    end loop;
    return rd_temp;
end function;	

-- Signed Integer Multiply-Subtract Low with Saturation: Multiply low 16-bit-fields of each 32-bit field of registers rs3 and rs2, 
-- then subtract 32-bit products from 32-bit fields of register rs1, and save result in register rd
function SignedIntegerMultiplySubtractLowWithSaturation(
    rs1 : in std_logic_vector(127 downto 0);
    rs2 : in std_logic_vector(127 downto 0);
    rs3 : in std_logic_vector(127 downto 0)
) return std_logic_vector is
variable result : signed(32 downto 0); 
variable product : signed(31 downto 0);
variable reg1 : signed(31 downto 0);
variable newreg1 : signed(32 downto 0);		
variable newproduct : signed(32 downto 0);
variable rd_temp : std_logic_vector(127 downto 0);
begin
    for i in 0 to 3 loop
        reg1 :=	signed(rs1(32*i + 31 downto 32*i));	 
		-- extend the rs1 to 33-bits before performing subtraction
		if (reg1(31) = '1') then
			newreg1 := '1' & reg1;
		else
			newreg1 := '0' & reg1;
		end if;	
		
		product := signed(rs3(32*i + 15 downto 32*i)) * signed(rs2(32*i + 15 downto 32*i));	   
		-- extend the product of the 16-bit fields in rs3 and rs2 to 33-bits before performing subtraction
		if (product(31) = '1') then
			newproduct := '1' & product;
		else
			newproduct := '0' & product;
		end if;
		
		-- Subtract the 33-bit values and determine if the result requires saturation
        result := newreg1 - newproduct;

        if result > to_signed(int_max, 33) then
            result := to_signed(int_max, 33);
        elsif result < to_signed(int_min, 33) then
            result := to_signed(int_min, 33);
        end if;

        rd_temp(32*i + 31 downto 32*i) := std_logic_vector(result(31 downto 0));
    end loop;
    return rd_temp;
end function; 

-- Signed Integer Multiply-Subtract High with Saturation: Multiply high 16-bit- fields of each 32-bit field of registers rs3 and rs2, 
-- then subtract 32-bit products from 32-bit fields of register rs1, and save result in register rd
function SignedIntegerMultiplySubtractHighWithSaturation(
    rs1 : in std_logic_vector(127 downto 0);
    rs2 : in std_logic_vector(127 downto 0);
    rs3 : in std_logic_vector(127 downto 0)
) return std_logic_vector is
variable result : signed(32 downto 0); 
variable product : signed(31 downto 0);
variable reg1 : signed(31 downto 0);
variable newreg1 : signed(32 downto 0);		
variable newproduct : signed(32 downto 0);
    variable rd_temp : std_logic_vector(127 downto 0);
begin
    for i in 0 to 3 loop  
		reg1 :=	signed(rs1(32*i + 31 downto 32*i));	
		-- extend the rs1 to 33-bits before performing subtraction
		if (reg1(31) = '1') then
			newreg1 := '1' & reg1;
		else
			newreg1 := '0' & reg1;
		end if;	
		
		product :=	signed(rs3(32*i + 31 downto 32*i + 16)) * signed(rs2(32*i + 31 downto 32*i + 16));
		-- extend the product of the 16-bit fields in rs3 and rs2 to 33-bits before performing subtraction
		if (product(31) = '1') then
			newproduct := '1' & product;
		else
			newproduct := '0' & product;
		end if;
		
		-- Subtract the 33-bit values and determine if the result requires saturation
        result := signed(newreg1) - signed(newproduct);	  

        if result > to_signed(int_max, 33) then
            result := to_signed(int_max, 33);
        elsif result < to_signed(int_min, 33) then
            result := to_signed(int_min, 33);
        end if;

        rd_temp(32*i + 31 downto 32*i) := std_logic_vector(result(31 downto 0));
    end loop;
    return rd_temp;
end function; 

-- Signed Long Integer Multiply-Add Low with Saturation: Multiply low 32-bit- fields of each 64-bit field of registers rs3 and rs2, 
-- then add 64-bit products to 64-bit fields of register rs1, and save result in register rd
function SignedLongIntegerMultiplyAddLowWithSaturation(
	rs1 : in std_logic_vector(127 downto 0);
    rs2 : in std_logic_vector(127 downto 0);
    rs3 : in std_logic_vector(127 downto 0)
) return std_logic_vector is
variable result: signed(63 downto 0);
variable unsigned_result : unsigned (64 downto 0);
	variable rd_temp : std_logic_vector(127 downto 0);
begin	
	for i in 0 to 1 loop	
		
		-- if product of 32-bit fields of rs3 and rs2 is positive and the 64-bit field of rs1 is positive
		if ((signed((signed(rs3(64*i + 31 downto 64*i)) * signed(rs2(64*i + 31 downto 64*i)))) > 0) and signed(rs1(64*i + 63 downto 64*i)) > 0) then
			unsigned_result(64) := '0';
			unsigned_result(63 downto 0) := unsigned(unsigned((unsigned(rs3(64*i + 31 downto 64*i)) * unsigned(rs2(64*i + 31 downto 64*i))))
            + unsigned(rs1(64*i + 63 downto 64*i)));	
			
			if unsigned_result > long_max then
            	result := signed(long_max);
			else
				result := signed(signed((signed(rs3(64*i + 31 downto 64*i)) * signed(rs2(64*i + 31 downto 64*i))))
            		+ signed(rs1(64*i + 63 downto 64*i)));
        	end if;
			
		-- if product of 32-bit fields of rs3 and rs2 is negative and the 64-bit field of rs1 is negative
		elsif ((signed((signed(rs3(64*i + 31 downto 64*i)) * signed(rs2(64*i + 31 downto 64*i)))) < 0 and signed(rs1(64*i + 63 downto 64*i)) < 0)) then
			unsigned_result := unsigned(signed(signed(rs3(64*i + 31 downto 64*i)) * signed(rs2(64*i + 31 downto 64*i)))) + unsigned(rs1(64*i + 63 downto 64*i));	 
			if signed(unsigned_result) < signed(long_min) then
            	result := signed(long_min);
			else
				result := signed(signed((signed(rs3(64*i + 31 downto 64*i)) * signed(rs2(64*i + 31 downto 64*i))))
				+ signed(rs1(64*i + 63 downto 64*i)));
			end if;
			
		else
			result := signed(signed((signed(rs3(64*i + 31 downto 64*i)) * signed(rs2(64*i + 31 downto 64*i))))
            + signed(rs1(64*i + 63 downto 64*i)));

        	if result > signed(long_max) then
            	result := signed(long_max);
        	elsif result < signed(long_min) then
            	result := signed(long_min);
        	end if;	
        end if;
			
        rd_temp(64*i + 63 downto 64*i) := std_logic_vector(result);
						
	end loop;
	return rd_temp;
end function;

-- Signed Long Integer Multiply-Add High with Saturation: Multiply high 32-bit- fields of each 64-bit field of registers rs3 and rs2, 
-- then add 64-bit products to 64-bit fields of register rs1, and save result in register rd
function SignedLongIntegerMultiplyAddHighWithSaturation(
	rs1 : in std_logic_vector(127 downto 0);
    rs2 : in std_logic_vector(127 downto 0);
    rs3 : in std_logic_vector(127 downto 0)
) return std_logic_vector is
variable result: signed(63 downto 0);
variable unsigned_result : unsigned (64 downto 0);
	variable rd_temp : std_logic_vector(127 downto 0);
begin			   
	 for i in 0 to 1 loop			   
		 
		-- if product of 32-bit fields of rs3 and rs2 is positive and the 64-bit field of rs1 is positive
		if ((signed((signed(rs3(64*i + 63 downto 64*i + 32)) * signed(rs2(64*i + 63 downto 64*i + 32)))) > 0) and signed(rs1(64*i + 63 downto 64*i)) > 0) then
			unsigned_result(64) := '0';
			unsigned_result(63 downto 0) := unsigned(unsigned((unsigned(rs3(64*i + 63 downto 64*i + 32)) * unsigned(rs2(64*i + 63 downto 64*i + 32))))
            + unsigned(rs1(64*i + 63 downto 64*i)));	
			
			if unsigned_result > long_max then
            	result := signed(long_max);
			else				   
				result := signed(signed((signed(rs3(64*i + 63 downto 64*i + 32)) * signed(rs2(64*i + 63 downto 64*i + 32))))
				+ signed(rs1(64*i + 63 downto 64*i)));																													 
        	end if;
		
		-- if product of 32-bit fields of rs3 and rs2 is negative and the 64-bit field of rs1 is negative
		elsif ((signed((signed(rs3(64*i + 63 downto 64*i + 32)) * signed(rs2(64*i + 63 downto 64*i + 32)))) < 0 and signed(rs1(64*i + 63 downto 64*i)) < 0)) then
			unsigned_result := '1' & unsigned(signed(signed(rs3(64*i + 63 downto 64*i + 32)) * signed(rs2(64*i + 63 downto 64*i + 32)))) + unsigned(rs1(64*i + 63 downto 64*i));	 
			if result < signed(long_min) then
            	result := signed(long_min);
			else
				result := signed(signed((signed(rs3(64*i + 63 downto 64*i + 32)) * signed(rs2(64*i + 63 downto 64*i + 32))))
				+ signed(rs1(64*i + 63 downto 64*i)));
			end if;
			
		else
			result := signed(signed((signed(rs3(64*i + 63 downto 64*i + 32)) * signed(rs2(64*i + 63 downto 64*i + 32))))
            + signed(rs1(64*i + 63 downto 64*i)));

        	if result > signed(long_max) then
            	result := signed(long_max);
        	elsif result < signed(long_min) then
            	result := signed(long_min);
        	end if;	
        end if;
			
        rd_temp(64*i + 63 downto 64*i) := std_logic_vector(result);
						
	end loop;
	return rd_temp;
end function;  

-- Signed Long Integer Multiply-Subtract Low with Saturation: Multiply low 32- bit-fields of each 64-bit field of registers rs3 and rs2, 
-- then subtract 64-bit products from 64-bit fields of register rs1, and save result in register rd
function SignedLongIntegerMultiplySubtractLowWithSaturation(
	rs1 : in std_logic_vector(127 downto 0);
    rs2 : in std_logic_vector(127 downto 0);
    rs3 : in std_logic_vector(127 downto 0)
) return std_logic_vector is
variable result: signed(64 downto 0); 
variable product : signed(63 downto 0);
variable reg1 : signed(63 downto 0);
variable newreg1 : signed(64 downto 0);		
variable newproduct : signed(64 downto 0);
	variable rd_temp : std_logic_vector(127 downto 0);
begin	
	 for i in 0 to 1 loop	   
		
		reg1 :=	signed(signed(rs1(64*i + 63 downto 64*i)));
		-- extend the rs1 to 65-bits before performing subtraction
		if (reg1(63) = '1') then
			newreg1 := '1' & reg1;
		else
			newreg1 := '0' & reg1;
		end if;	
		
		product :=	signed((signed(rs3(64*i + 31 downto 64*i)) * signed(rs2(64*i + 31 downto 64*i))));
		-- extend the product of the 32-bit fields in rs3 and rs2 to 65-bits before performing subtraction
		if (product(63) = '1') then
			newproduct := '1' & product;
		else
			newproduct := '0' & product;
		end if;
		
		-- Subtract the 65-bit values and determine if the result requires saturation
        result := newreg1 - newproduct;

        if result > signed(long_max) then
            result := '0' & signed(long_max);
        elsif result < signed(long_min) then
            result := '1' & signed(long_min);
        end if;

        rd_temp(64*i + 63 downto 64*i) := std_logic_vector(result(63 downto 0));
						
	end loop;
	return rd_temp;
end function;

-- Signed Long Integer Multiply-Subtract High with Saturation: Multiply high 32- bit-fields of each 64-bit field of registers rs3 and rs2, 
-- then subtract 64-bit products from 64-bit fields of register rs1, and save result in register rd
function SignedLongIntegerMultiplySubtractHighWithSaturation(
	rs1 : in std_logic_vector(127 downto 0);
    rs2 : in std_logic_vector(127 downto 0);
    rs3 : in std_logic_vector(127 downto 0)
) return std_logic_vector is
variable result: signed(64 downto 0);  
variable product : signed(63 downto 0);
variable reg1 : signed(63 downto 0);
variable newreg1 : signed(64 downto 0);		
variable newproduct : signed(64 downto 0);
	variable rd_temp : std_logic_vector(127 downto 0);
begin	
	 for i in 0 to 1 loop		   
		
		reg1 :=	signed(signed(rs1(64*i + 63 downto 64*i)));
		-- extend the rs1 to 65-bits before performing subtraction
		if (reg1(63) = '1') then
			newreg1 := '1' & reg1;
		else
			newreg1 := '0' & reg1;
		end if;	
		
		product :=	signed((signed(rs3(64*i + 63 downto 64*i + 32)) * signed(rs2(64*i + 63 downto 64*i + 32))));
		-- extend the product of the 32-bit fields in rs3 and rs2 to 65-bits before performing subtraction
		if (product(63) = '1') then
			newproduct := '1' & product;
		else
			newproduct := '0' & product;
		end if;
		
		-- Subtract the 65-bit values and determine if the result requires saturation
        result := newreg1 - newproduct;

        if result > signed(long_max) then
            result := '0' & signed(long_max);
        elsif result < signed(long_min) then
            result := '1' & signed(long_min);
        end if;

        rd_temp(64*i + 63 downto 64*i) := std_logic_vector(result(63 downto 0));
						
	end loop;
	return rd_temp;
end function;	 

-- Shift Right Halfword Immediate: Shifts the contents of each halfword in register rs1 by the amount specified 
-- in the least significant 4 bits of register rs2. The result is saved in register rd.
function SHRHI(
	rs1 : in std_logic_vector(127 downto 0);
    rs2 : in std_logic_vector(127 downto 0)
) return std_logic_vector is
	variable shift_amount: integer;
	variable rd_temp : std_logic_vector(127 downto 0);
begin
	shift_amount := to_integer(unsigned(rs2(3 downto 0)));
	for i in 0 to 7 loop
		rd_temp(16*i + 15 downto 16*i) := (others => '0');
		
		-- set bits (15 - shift) to 0 of rd with bits 16 to shift of rs1
		for j in 0 to (15 - shift_amount) loop
			rd_temp(16*i + j) := rs1(16*i + j + shift_amount);
		end loop;
		for j in (15 - shift_amount) to 15 loop
			rd_temp(16*i + j) := '0';
		end loop;
	end loop;  
	return rd_temp;
end function;  

-- Count 1s in Halfword: Counts the number of '1' bits in each halfword of register rs1 and saves the value to register rd
function CNT1H(
	rs1 : in std_logic_vector(127 downto 0);
    rs2 : in std_logic_vector(127 downto 0)
) return std_logic_vector is
	variable count: integer := 0;
	variable rd_temp : std_logic_vector(127 downto 0);
begin
	for i in 0 to 7 loop
		count := 0;
		for j in 0 to 15 loop
			if rs1(i*16 + j) = '1' then
				count := count + 1;
			end if;
		end loop;
		rd_temp(i*16 + 15 downto i*16) := std_logic_vector(to_unsigned(count, 16));
	end loop;  
	return rd_temp;
end function;	  

-- AHS: add halfword saturated : packed 16-bit halfword signed addition with saturation of the contents of registers rs1 and rs2. (Comments: 8 separate 16-bit values in each 128-bit register)
function AHS(
	rs1 : in std_logic_vector(127 downto 0);
    rs2 : in std_logic_vector(127 downto 0)
) return std_logic_vector is
	variable rs1_halfword, rs2_halfword: signed(15 downto 0);	 
	variable result : signed(15 downto 0);
	variable rd_temp : std_logic_vector(127 downto 0);
begin
	for i in 0 to 7 loop   
		rs1_halfword := signed(rs1(16*i + 15 downto 16*i));
		rs2_halfword := signed(rs2(16*i + 15 downto 16*i));	
		
		-- check if both halfwords are positive and if saturation is required
		if (rs1_halfword > 0) and (rs2_halfword > 0) then		
			if to_integer(rs1_halfword) + to_integer(rs2_halfword) > 32767 then 		  
				result := to_signed(32767, 16);
			else
				result := signed(rs1_halfword + rs2_halfword);
			end if;
		-- check if both halfwords are negative and if saturation is required
		elsif (rs1_halfword < 0) and (rs2_halfword < 0) then	
			if to_signed(to_integer(rs1_halfword) + to_integer(rs2_halfword), 17) < to_signed(-32768, 16) then
        		result := to_signed(-32768, 16);   
			else
				result := signed(rs1_halfword + rs2_halfword);				
			end if;
		else
			result := signed(rs1_halfword + rs2_halfword);
		end if;		  
						
		rd_temp(16*i + 15 downto 16*i) := std_logic_vector(result);
	end loop;  
	return rd_temp;
end function;  

-- MLHSS: multiply by sign saturated: Multiply the value of each halfword in rs1 by the sign of the corresponding halfword in rs2. This effectively
-- takes the two's complement of the halfwords in rs1 if the sign of the halfword in rs2 is negative, otherwise the halfword will equal that of rs1.
-- If the value of the halfword in rs2 is 0, then the resulting value of the corresponding halfword will be 0. Result is stored in register rd.
function MLHSS(
	rs1 : in std_logic_vector(127 downto 0);
    rs2 : in std_logic_vector(127 downto 0)
) return std_logic_vector is
	variable rs1_halfword, rs2_halfword: signed(15 downto 0);
	variable rd_temp: std_logic_vector(127 downto 0);
	variable result: signed(15 downto 0);
begin 
	for i in 0 to 7 loop
		
        rs1_halfword := signed(rs1(16*i + 15 downto 16*i));
		rs2_halfword := signed(rs2(16*i + 15 downto 16*i));	
		
		-- if the sign of the halfword in rs2 is negative, multiply halfword of rs1 by -1. Perform saturation if necessary.
		if rs2_halfword(15) = '1' then
			if rs1_halfword < to_signed(-32768, 16) then
				result := to_signed(32767, 16);
			else
				result := to_signed(to_integer(rs1_halfword) * (-1), 16);
			end if;	
		-- if the sign of the halfword in rs2 is positive, the resulting halfword is that of rs1.
		elsif to_integer(rs2_halfword) = 0 then
			result := rs2_halfword;
		else
			result := rs1_halfword;	
		end if;	 	  
						
		rd_temp(16*i + 15 downto 16*i) := std_logic_vector(result);
		
    end loop;
	return rd_temp;
end function;

		
-- SFHS: subtract from halfword saturated: packed 16-bit halfword signed subtraction with saturation of the contents of rs1 from rs2 (rd = rs2 - rs1). 
-- (Comments: 8 separate 16-bit values in each 128-bit register)
function SFHS(
	rs1 : in std_logic_vector(127 downto 0);
    rs2 : in std_logic_vector(127 downto 0)
) return std_logic_vector is
variable rs1_halfword, rs2_halfword: signed(15 downto 0);
variable result : signed(15 downto 0);
	variable rd_temp : std_logic_vector(127 downto 0);
begin
	for i in 0 to 7 loop   
		
		rs1_halfword := signed(rs1(16*i + 15 downto 16*i));
		rs2_halfword := signed(rs2(16*i + 15 downto 16*i));	
		
		-- if negative number subtracted from positive number, check if positive saturation is necessary
		if (rs1_halfword < 0) and (rs2_halfword > 0) then		  
			if to_signed(to_integer(rs2_halfword) - to_integer(rs1_halfword), 17) > to_signed(32767, 16) then
				result := to_signed(32767, 16);
			else
				result := signed(rs2_halfword - rs1_halfword);
			end if;
		-- if positive number subtracted from a negative number, check if negative saturation is necessary
		elsif (rs1_halfword > 0) and (rs2_halfword < 0) then	
			if to_signed(to_integer(rs2_halfword) - to_integer(rs1_halfword), 17) < to_signed(-32768, 16) then
        		result := to_signed(-32768, 16);   
			else
				result := signed(rs2_halfword - rs1_halfword);				
			end if;
		else
			result := signed(rs2_halfword - rs1_halfword);
		end if;		  
						
		rd_temp(16*i + 15 downto 16*i) := std_logic_vector(result);
		
	end loop;  
	return rd_temp;
end function;		

begin
	process (instr, opcode, rs3, rs2, rs1)
	begin 
		if (instr = "10") then 		-- *** Multiply-Add and Multiply-Subtract R4-Instruction Format ***		
			if (std_match(opcode, "-----000")) then 		-- Signed Integer Multiply-Add Low with Saturation .
				rd <= SignedIntegerMultiplyAddLowWithSaturation(rs1, rs2, rs3);
			elsif (std_match(opcode, "-----001")) then 	-- Signed Integer Multiply-Add High with Saturation
				rd <= SignedIntegerMultiplyAddHighWithSaturation(rs1, rs2, rs3);
			elsif (std_match(opcode, "-----010")) then 	-- Signed Integer Multiply-Subtract Low with Saturation
				rd <= SignedIntegerMultiplySubtractLowWithSaturation(rs1, rs2, rs3);
			elsif (std_match(opcode, "-----011")) then 	-- Signed Integer Multiply-Subtract High with Saturation
				rd <= SignedIntegerMultiplySubtractHighWithSaturation(rs1, rs2, rs3);
			elsif (std_match(opcode, "-----100")) then 	-- Signed Long Integer Multiply-Add Low with Saturation	
				rd <= SignedLongIntegerMultiplyAddLowWithSaturation(rs1, rs2, rs3);
			elsif (std_match(opcode, "-----101")) then 	-- Signed Long Integer Multiply-Add High with Saturation 	   
				rd <= SignedLongIntegerMultiplyAddHighWithSaturation(rs1, rs2, rs3);
			elsif (std_match(opcode, "-----110")) then 	-- Signed Long Integer Multiply-Subtract Low with Saturation
				rd <= SignedLongIntegerMultiplySubtractLowWithSaturation(rs1, rs2, rs3);
			elsif (std_match(opcode, "-----111")) then 	-- Signed Long Integer Multiply-Subtract High with Saturation
				rd <= SignedLongIntegerMultiplySubtractHighWithSaturation(rs1, rs2, rs3);	
			end if;	
		elsif (instr = "11") then 	-- *** R3-Instruction Format ***	 
			-- if (opcode = "----0000") then 		-- NOP: no operation
			if (std_match(opcode, "----0001")) then 	-- SHRHI: shift right halfword immediate
				rd <= SHRHI(rs1, rs2);
			elsif (std_match(opcode, "----0010")) then 	-- AU: add word unsigned 
				-- AU: add word unsigned: packed 32-bit unsigned addition of the contents of registers rs1 and rs2 (Comments: 4 separate 32-bit values in each 128-bit register)
				rd <= std_logic_vector(unsigned(rs1(127 downto 96)) + unsigned(rs2(127 downto 96)))	
				& std_logic_vector(unsigned(rs1(95 downto 64)) + unsigned(rs2(95 downto 64)))
				& std_logic_vector(unsigned(rs1(63 downto 32)) + unsigned(rs2(63 downto 32)))
				& std_logic_vector(unsigned(rs1(31 downto 0)) + unsigned(rs2(31 downto 0)));
			elsif (std_match(opcode, "----0011")) then 	-- CNT1H: count 1s in halfword
				rd <= CNT1H(rs1, rs2);
			elsif (std_match(opcode, "----0100")) then 	-- AHS: add halfword saturated
				rd <= AHS(rs1, rs2);
			elsif (std_match(opcode, "----0101")) then 	-- OR: bitwise logical 'or' of the contents of registers rs1 and rs2  	 																								 
				rd <= rs1 or rs2;
			elsif (std_match(opcode, "----0110")) then 	-- BCW: broadcast word 
				-- BCW: broadcast word: the least significant word of register rs1 is copied to all 4 words of register rd
				rd <= rs1(31 downto 0) & rs1(31 downto 0) & rs1(31 downto 0) & rs1(31 downto 0);
			elsif (std_match(opcode, "----0111")) then 	-- MAXWS: max signed word
				-- MAXWS: max signed word: for each of the four 32-bit word slots, place the maximum signed value between rs1 and rs2 in register rd. 
				-- (Comments: 4 separate 32-bit values in each128-bit register)
				if (signed(rs1(127 downto 96)) >= signed(rs2(127 downto 96))) then
					rd(127 downto 96) <= rs1(127 downto 96);
				else
					rd(127 downto 96) <= rs2(127 downto 96);
				end if;	   
				
				if (signed(rs1(95 downto 64)) >= signed(rs2(95 downto 64))) then
					rd(95 downto 64) <= rs1(95 downto 64);
				else
					rd(95 downto 64) <= rs2(95 downto 64);
				end if;
				
				if (signed(rs1(63 downto 32)) >= signed(rs2(63 downto 32))) then
					rd(63 downto 32) <= rs1(63 downto 32);
				else
					rd(63 downto 32) <= rs2(63 downto 32);
				end if;	   
				
				if (signed(rs1(31 downto 0)) >= signed(rs2(31 downto 0))) then
					rd(31 downto 0) <= rs1(31 downto 0);
				else
					rd(31 downto 0) <= rs2(31 downto 0);
				end if;
			elsif (std_match(opcode, "----1000")) then 	-- MINWS: min signed word 
				-- MINWS: min signed word: for each of the four 32-bit word slots, place the minimum  signed value between rs1 and rs2 in register rd . 
				-- (Comments: 4 separate 32-bit values in each 128-bit register)
				if (signed(rs1(127 downto 96)) <= signed(rs2(127 downto 96))) then
					rd(127 downto 96) <= rs1(127 downto 96);
				else
					rd(127 downto 96) <= rs2(127 downto 96);
				end if;	   
				
				if (signed(rs1(95 downto 64)) <= signed(rs2(95 downto 64))) then
					rd(95 downto 64) <= rs1(95 downto 64);
				else
					rd(95 downto 64) <= rs2(95 downto 64);
				end if;
				
				if (signed(rs1(63 downto 32)) <= signed(rs2(63 downto 32))) then
					rd(63 downto 32) <= rs1(63 downto 32);
				else
					rd(63 downto 32) <= rs2(63 downto 32);
				end if;	   
				
				if (signed(rs1(31 downto 0)) <= signed(rs2(31 downto 0))) then
					rd(31 downto 0) <= rs1(31 downto 0);
				else
					rd(31 downto 0) <= rs2(31 downto 0);
				end if;
			elsif (std_match(opcode, "----1001")) then 	-- MLHU: multiply low unsigned	 
				-- MLHU: multiply low unsigned: the 16 rightmost bits of each of the four 32-bit slots in register rs1 are multiplied by 
				-- the 16 rightmost bits of the corresponding 32-bit slots in register rs2, treating both operands as unsigned. The four 
				-- 32-bit products are placed into the corresponding slots of register rd . (Comments: 4 separate 32-bit values in each 128-bit register)
				rd <= std_logic_vector(unsigned(rs1(111 downto 96)) * unsigned(rs2(111 downto 96)))
				& std_logic_vector(unsigned(rs1(79 downto 64)) * unsigned(rs2(79 downto 64)))
				& std_logic_vector(unsigned(rs1(47 downto 32)) * unsigned(rs2(47 downto 32)))
				& std_logic_vector(unsigned(rs1(15 downto 0)) * unsigned(rs2(15 downto 0)));
			elsif (std_match(opcode, "----1010")) then 	-- MLHSS: multiply by sign saturated
				rd <= MLHSS(rs1, rs2);
			elsif (std_match(opcode, "----1011")) then 	-- AND: bitwise logical 'and' of the contents of registers rs1 and rs2	
				rd <= rs1 and rs2;
			elsif (std_match(opcode, "----1100")) then 	-- INVB: invert (flip) bits of the contents of register rs1
				--rd <= std_logic_vector(unsigned(rs1'range => '1') - unsigned(rs1)); 
				rd <= not rs1;
			elsif (std_match(opcode, "----1101")) then 	-- ROTW: rotate bits in word 
				-- ROTW: rotate bits in word : the contents of each 32-bit field in register rs1 are rotated to the right according to the value of the 5 least significant bits 
				-- of the corresponding 32-bit field in register rs2. The results are placed in register rd. Bits rotated out of the right end of each word are rotated in on the 
				-- left end of the same 32-bit word field. (Comments: 4 separate 32-bit word values in each 128-bit register)	 
				rd <= rs1(95 + to_integer(unsigned(rs2(100 downto 96))) downto 96) & rs1(127 downto 96 + to_integer(unsigned(rs2(100 downto 96)))) 
				& rs1(63 + to_integer(unsigned(rs2(68 downto 64))) downto 64) & rs1(95 downto 64 + to_integer(unsigned(rs2(68 downto 64))))
				& rs1(31 + to_integer(unsigned(rs2(36 downto 32))) downto 32) & rs1(63 downto 32 + to_integer(unsigned(rs2(36 downto 32))))
				& rs1(-1 + to_integer(unsigned(rs2(4 downto 0))) downto 0) & rs1(31 downto 0 + to_integer(unsigned(rs2(4 downto 0))));
			elsif (std_match(opcode, "----1110")) then 	-- SFWU: subtract from word unsigned
				-- SFWU: subtract from word unsigned: packed 32-bit word unsigned subtract of the contentsof rs1 from rs2 (rd = rs2 - rs1). 
				-- (Comments: 4 separate 32-bit values in each 128-bit register)
				rd <= std_logic_vector(unsigned(rs2(127 downto 96)) - unsigned(rs1(127 downto 96)))	
				& std_logic_vector(unsigned(rs2(95 downto 64)) - unsigned(rs1(95 downto 64)))
				& std_logic_vector(unsigned(rs2(63 downto 32)) - unsigned(rs1(63 downto 32)))
				& std_logic_vector(unsigned(rs2(31 downto 0)) - unsigned(rs1(31 downto 0)));
			elsif (std_match(opcode, "----1111")) then 	-- SFHS: subtract from halfword saturated
				rd <= SFHS(rs1, rs2);  
			end if;	
		else 						-- *** Load Immediate ***
			rd <= rs1(127 downto (to_integer(unsigned(load_index))+1)*16) & imm & rs1(to_integer(unsigned(load_index))*16-1 downto 0);
		end if;
	end process;
end alu;

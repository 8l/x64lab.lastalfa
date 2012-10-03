	;--- This code is public domain.-------------------------------------

	;----------------------display_hex numbits,symbolic const------------
	;	FROM BOARD flatassembler.net
	;	VERSION 31 März 2008
	;-----------
	macro display_hex bits,symb_const
		 {
		tmpbits 	= bits
		tmpvalue	= symb_const 
		repeat tmpbits/4
			d = '0' + tmpvalue shr (tmpbits-%*4) and 0Fh
			if d > "9"
				d = d + "A"-"9"-1
			end if
			display d
		end repeat
	 	}

	;----------------------display_decimal value-----------------
	;	FROM BOARD flatassembler.net
	;	VERSION 24 Dec 2007, 13:03
	;	AUTHOR: revolution
	;-----------
	macro display_decimal value*,put_zeros {
    	local leading_zero,digit,divisor,number
    	number=value
    	if number=1 shl 63
        	display '-9223372036854775808'
    	else
        	if number<0
            	number=-number
            	display '-'
        	end if
        	leading_zero=put_zeros+0
        	divisor=1000000000000000000
        	while divisor>0
            	digit=number/divisor
            	leading_zero=leading_zero+digit
            	if leading_zero | (divisor=1)
                	display digit+'0'
					number=number-digit*divisor
				end if
				divisor=divisor/10
			end while
		end if
	}

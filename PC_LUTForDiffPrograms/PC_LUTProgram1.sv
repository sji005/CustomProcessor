module PC_LUT #(parameter D=12)(
  input       [ 2:0] addr,	   // target 4 values
  input 	         thirdBit,
  output logic[D-1:0] target);

  always_comb case({thirdBit, addr})
    0: target = 32;   // loop1
	1: target = 52;   // sndPart
	2: target = 61;   //loop2
	3: target = 73;   //computeFloat
	4: target = 102;   //loop3
	5: target = 115;   //assemble
	6: target = 145;   //isZero
	7: target = 400;  //done
	8: target = 157;    //loop align
	9: target = 173;  //ifMostNeg
	default: target = 'b0;  // hold PC  
  endcase

endmodule

/*

	   pc = 4    0000_0000_0100	  4
	             1111_1111_1111	 -1

                 0000_0000_0011   3

				 (a+b)%(2**12)


   	  1111_1111_1011      -5
      0000_0001_0100     +20
	  1111_1111_1111      -1
	  0000_0000_0000     + 0


  */

module PC_LUT #(parameter D=12)(
  input       [ 2:0] addr,	   // target 4 values
  input 	         thirdBit,
  output logic[D-1:0] target);

  always_comb case({thirdBit, addr})
    0: target = 81;   // loop A
	1: target = 98;   //addMantissaA 
	2: target = 142;   //assemble
	3: target = 185;   //shiftB
	4: target = 216;   //loopB
	5: target = 272;   //preAssembleB
	6: target = 285;   //preAssembleA
	7: target = 400;  //done
	8: target = 159;    
	9: target = 175;  
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

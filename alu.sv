// combinational -- no clock
// sample -- change as desired
module alu(
  input[2:0] alu_cmd,    // ALU instructions
  input[7:0] inA, inB,	 // 8-bit wide data path
  input      sc_i,       // shift_carry in
  output logic[7:0] rslt,
  output logic sc_o,     // shift_carry out
               neg,     // reduction XOR (output)
			   zero      // NOR (output)
);

always_comb begin 
  zero = 0;
  neg = 0;
  rslt = 'b0;            
  sc_o = 'b0;    
  case(alu_cmd)
    3'b000: begin // add 2 8-bit unsigned; automatically makes carry-out
      {sc_o,rslt} = inA + inB;
      neg = (rslt[7]); // check if result is negative
    end
	3'b001: // left_shift
	  {sc_o,rslt} = {inA, sc_i};
      /*begin
		rslt[7:1] = ina[6:0];
		rslt[0]   = sc_i;
		sc_o      = ina[7];
      end*/
    3'b010: begin //flip nth bit
        if (inA <= 0 || inA > 16) begin
          rslt = inB;
        end else if (sc_i == 1 && inA > 8) begin
          rslt = inB; // flip bit inB at position inA-9
          rslt[inA-9] = ~inB[inA-9];
        end else if (sc_i == 0 && inA > 8) begin
          zero = 1; //
          rslt = inB;
        end else if(sc_i == 1 && inA <= 8) begin
          rslt = inB; // flip bit inB at position inA-1
        end else if (sc_i == 0 && inA <= 8) begin
          zero = 1; // flip on lsb part
          rslt = inB;
          rslt[inA-1] = ~inB[inA-1];
        end else begin
          rslt = inB; // default case, output zero
        end
    end
    3'b011: // bitwise XOR
	  rslt = inA ^ inB;
	3'b100: // bitwise AND (mask)
	  rslt = inA & inB;
	3'b101: // left rotate
	  rslt = {inA[6:0],inA[7]};
	3'b110: begin // subtract
	  rslt = inB - inA;
    if(({1'b0, (~inA + 8'b1)} + inB) >= 9'b100000000) begin
      sc_o = 1;
    end
    zero = (rslt == 'b0);
    neg = (rslt[7]);
  end
	3'b111: // or A
	  rslt = inA | inB;
  endcase
end
   
endmodule
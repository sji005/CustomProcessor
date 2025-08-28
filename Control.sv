// control decoder
module Control #(parameter opwidth = 3, mcodebits = 9)(
  input [mcodebits-1:0] instr,    // subset of machine code (any width you need)
  output logic WantZero, Branch, 
     MemtoReg, MemWrite, ALUSrc, RegWrite, regOpOrOther,
  output logic[opwidth-1:0] ALUOp);	   // for up to 8 ALU operations

always_comb begin
// defaults
  WantZero 	=   'b0;   // do we set the first operand as zero
  Branch 	=   'b0;   // 1: branch (jump)
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	=	'b0;   // 1: immediate  0: second reg file output
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  ALUOp	    =   'b111; // y = a+0;
  regOpOrOther = 0; // 1: use regOp module, 0: use ALU
// sample values only -- use what you need
case(instr[8:6])    // override defaults with exceptions
  'b000:  begin		//or 
          ALUOp = 3'b111;      
			 end
  'b001:  ALUOp      = 'b010; //flip bits
  'b010:  begin				 //sub 
            
			    ALUOp = 3'b110;    
        end
  'b011: begin //branch
    ALUOp = 3'b000; 
    Branch = 1'b1; //branch if equal
    RegWrite = 1'b0; //no write to reg file
  end
  'b100: begin //mv immediate
    ALUOp = 3'b000; //add
    ALUSrc = 1; //immediate value
    WantZero = 1; //set first operand to zero
  end
  'b101: begin //load
    MemtoReg = 1;
  end
  'b110: begin //store
    RegWrite = 0; 
    MemWrite = 1;
  end
  'b111: begin //regOp usage
    regOpOrOther = 1; // use regOp module
  end
// ...
endcase

//for done signal, raise flag intop level and pass in a no op to the controller


end
	
endmodule
// sample top level design
module TopLevel(
  input        clk, reset, start, 
  output logic done);
  parameter D = 12,             // program counter width
    A = 3;             		  // ALU command bit width
  wire[D-1:0] target, 			  // jump 
              prog_ctr;
  wire        RegWrite;
  wire[7:0]   datA,datB,		  // from RegFile
              muxB, 
              muxA,
			        rslt,
              regOpDatOut;               // alu output
  wire[2:0]   immed;
  logic sc_in,   				  // shift/carry out from/to ALU
        sc_o,                  // shift/carry out from ALU
        sc_iQ,
   		negQ,              	  // registered parity flag from ALU
		zeroQ,
    zeroQQ,                    // registered zero flag from ALU 
    regOpChange,
    regOpChangeQ,
    carry,
    carryQ;
  logic how_high;               // for PC_LUT
  logic   relj; 
  logic   absj;                    // from control to PC; absolute jump enable
  wire  neg,
        zero,
		sc_clr,
		sc_en,
        MemWrite,
        ALUSrc,		              // immediate switch
        regOpOrOther;          // if regOp, use regOp output, else ALU or memory output
  wire[A-1:0] alu_cmd;
  wire[8:0]   mach_code;          // machine code
  wire[2:0] rd_addrA, rd_addrB;    // address pointers to reg_file

  wire memOrAlu;
  wire [7:0] mem_datOut;
  wire [7:0] regfile_dat, regfile_datCmp1; // data to write to reg file
  wire WantZero;
  wire startReset;
  assign startReset = reset | start; // reset or request starts the program
// fetch subassembly
  PC #(.D(D)) 					  // D sets program counter width
     pc1 (.reset (startReset)            ,
         .clk              ,
		 .reljump_en (relj),
		 .absjump_en (absj),
		 .target           ,
		 .prog_ctr          );

// lookup table to facilitate jumps/branches;
  PC_LUT #(.D(D))
    pl1 (.addr  (immed),
         .thirdBit (mach_code[5]),
         .target          );   

// contains machine code
  instr_ROM ir1(.prog_ctr,
               .mach_code);

// control decoder
  Control ctl1(.instr(mach_code),
  .WantZero  , 
  .Branch  (isj)  , 
  .MemWrite , 
  .ALUSrc   , 
  .RegWrite   ,     
  .MemtoReg(memOrAlu),
  .ALUOp(alu_cmd),
  .regOpOrOther(regOpOrOther));

  assign rd_addrA = mach_code[2:0];
  assign rd_addrB = mach_code[5:3];
  assign immed = mach_code[2:0]; // immediate value

  always_comb begin
    if (mach_code[4:3] == 2'b00) begin //default equal situation with 2 conditions
      absj = isj & zeroQ & zeroQQ; // branch if previous alu instruction is zero (so 2 numbers equal)
    end else if(mach_code[4:3] == 2'b01) begin // if last alu value is negative
      absj = isj & negQ;
    end else if(mach_code[4:3] == 2'b10) begin // if last alu value is positive
      absj = isj && ~negQ && ~zeroQ; // branch if previous alu instruction is positive
    end else begin
      absj = 1'b0; // no branch
    end
  end

  assign regfile_datCmp1 = memOrAlu ? mem_datOut : rslt;
  assign regfile_dat = regOpOrOther ? regOpDatOut : regfile_datCmp1; // if regOp, use regOp output, else use ALU or memory output


  reg_file #(.pw(3)) rf1(.dat_in(regfile_dat),	   // loads, most ops
              .clk         ,
              .wr_en   (RegWrite),
              .rd_addrA(rd_addrA),
              .rd_addrB(rd_addrB),
              .wr_addr (rd_addrB),      // in place operation //might change based on immediate value 
              .datA_out(datA),
              .datB_out(datB)); 

  assign muxB = ALUSrc? immed : datB;
  assign muxA = WantZero ? 8'b0 : datA; // set first operand to zero if needed

  alu alu1(.alu_cmd,
         .inA    (muxA),
		 .inB    (muxB),
		 .sc_i   (zeroQ),   // output from sc register
		 .rslt       ,
		 .sc_o   (carry), // input to sc register
		 .neg (neg),
     .zero (zero) );  

  RegOp regOp (.reg_cmd (immed),
              .isChange (regOpChangeQ),
              .dat_in (datB),
              .sc_i (sc_iQ), // carry in
              .outDat (regOpDatOut),
              .isChangeOut (regOpChange),
              .carry (carryQ),
              .sc_o (sc_o)
  );

  data_mem data_mem1(.dat_in(datB)  ,  // from reg_file
             .clk           ,
			 .wr_en  (MemWrite), // stores
			 .addr   (datA),
             .dat_out(mem_datOut));

// registered flags from ALU
  always_ff @(posedge clk) begin
	  zeroQ <= zero;
    zeroQQ <= zeroQ;
	  sc_in <= 'b0;
    sc_iQ <= sc_o; // carry in to RegOp
    negQ <= neg;
    carryQ <= carry;
    regOpChangeQ <= regOpOrOther ? regOpChange : 0; // register change flag from RegOp
    // else if(sc_en)
    //   sc_in <= sc_o;
  end

  assign done = (prog_ctr == 400); //example just raised flag when it hit the certain pc
 
endmodule
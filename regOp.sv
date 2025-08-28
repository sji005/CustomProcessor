module RegOp ( //flexible register operations
    input[2:0] reg_cmd,
    input      isChange,
    input[7:0] dat_in,
    input      sc_i,
    input     carry, // carry in for increment operation
    output logic[7:0] outDat,
    output logic      sc_o, // carry out
    output logic isChangeOut
);

always_comb begin
    isChangeOut = 0;
    outDat = 'b0; // Default output
    sc_o = 0;
    case(reg_cmd)
        3'b000: begin //if negative then xor
            if (isChange == 0 && dat_in[7] == 1'b1) begin // Check if msp is negative
                outDat = ~dat_in;
                isChangeOut = 1; // Indicate a change occurred 
            end else begin
                outDat = dat_in; // No change, output original data
            end
        end
        3'b001: begin
            if (isChange) begin
                {isChangeOut, outDat} = { 1'b0, ~dat_in } + 1'b1;
            end else begin
                outDat = dat_in;
            end

        end
        3'b010: {outDat, sc_o} = {sc_i, dat_in}; // shift right with carry
        3'b011: outDat = dat_in + 1 + isChange; // increment op
        3'b100: begin 
            if (isChange) begin
                outDat = {1'b1, dat_in[6:0]}; //if prev negative then set msb to 1
            end else begin
                outDat = dat_in; //if prev positive then set msb to 0
            end
        end
        3'b101: outDat = {1'b0, dat_in}; //regular right shift without zero
        3'b110: {sc_o ,outDat} = {dat_in, sc_i}; //shift left
        3'b111: outDat = carry ? (dat_in + 1) : dat_in; //increment if sub contains carry, else returns itself;
        default: outDat = 'b0; // Default case, output zero
    endcase
end

endmodule
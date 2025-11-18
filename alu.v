module alu #(
    parameter WIDTH = 8         // parameter for width, default is 8 bits
)(
    input wire [WIDTH-1:0] a,   // input operand a
    input wire [WIDTH-1:0] b,   // input operand b
    input wire [2:0] op,        // operation selector

    output reg [WIDTH-1:0] y,   // output result
    output reg overflow,        // overflow flag (for signed arithmetic)
    output reg carry,           // carry/borrow flag (for unsigned arithmetic)
    output reg zero,            // zero flag
    output reg negative         // negative flag
);

    // operation params (better organization for cases)
    localparam OP_ADD = 3'b000;   // add
    localparam OP_SUB = 3'b001;   // subtract
    localparam OP_AND = 3'b010;   // and
    localparam OP_OR  = 3'b011;   // or
    localparam OP_XOR = 3'b100;   // xor
    localparam OP_SLL = 3'b101;   // bit shift left logical (unsigned)
    localparam OP_SRL = 3'b110;   // bit shift right logical (unsigned)
    localparam OP_SRA = 3'b111;   // bit shift right arithmetic (signed)

    reg [WIDTH:0] temp_result;    // temporary result with extra bit for carry

    // combinational logic for operations (no clock)
    always @(*) begin
        y = {WIDTH{1'b0}};   // default outputs
        overflow = 1'b0;
        carry = 1'b0;
        zero = 1'b0;
        negative = 1'b0;

        temp_result = {(WIDTH+1){1'b0}};

        // cases for operations
        case (op)
            OP_ADD: begin
                temp_result = {1'b0, a} + {1'b0, b};                                   // temporary result with carry
                y = temp_result[WIDTH-1:0];                                            // output result
                carry = temp_result[WIDTH];                                            // carry flag for unsigned
                overflow = (a[WIDTH-1] == b[WIDTH-1]) && (y[WIDTH-1] != a[WIDTH-1]);   // overflow for signed (same sign inputs leading to different sign output, overflow)
            end
            OP_SUB: begin
                temp_result = {1'b0, a} - {1'b0, b};                                   // temporary result with borrow
                y = temp_result[WIDTH-1:0];                                            // output result
                carry = temp_result[WIDTH];                                            // borrow flag for unsigned
                overflow = (a[WIDTH-1] != b[WIDTH-1]) && (y[WIDTH-1] != a[WIDTH-1]);   // overflow for signed (different sign inputs leading to different sign output, overflow)
            end
            OP_AND: begin
                y = a & b;   // bitwise and
            end
            OP_OR: begin
                y = a | b;   // bitwise or
            end
            OP_XOR: begin
                y = a ^ b;   // bitwise xor
            end
            OP_SLL: begin
                y = (b >= WIDTH) ? (a << (WIDTH-1)) : (a << b);   // logical left shift by b for unsigned (b saturated at width-1)
            end
            OP_SRL: begin
                y = (b >= WIDTH) ? (a >> (WIDTH-1)) : (a >> b);   // logical right shift by b for unsigned (b saturated at width-1)
            end
            OP_SRA: begin
                y = (b >= WIDTH) ? ($signed(a) >>> (WIDTH-1)) : ($signed(a) >>> b);   // arithmetic right shift by b for signed (b saturated at width-1)
            end
            default: begin
                y = {WIDTH{1'b0}};   // default case
            end
        endcase

        // set remaining flags
        zero = (y == {WIDTH{1'b0}});    // zero flag
        negative = y[WIDTH-1];          // negative flag for signed
    end
endmodule
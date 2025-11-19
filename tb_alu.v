`timescale 1ns/1ps

module tb_alu;
    parameter WIDTH = 8;

    // DUT inputs
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    reg [2:0] op;

    // DUT outputs
    wire [WIDTH-1:0] y;
    wire overflow;
    wire carry;
    wire zero;
    wire negative;

    // instantiate the ALU
    alu #(.WIDTH(WIDTH)) dut (
        .a(a),
        .b(b),
        .op(op),
        .y(y),
        .overflow(overflow),
        .carry(carry),
        .zero(zero),
        .negative(negative)
    );

    integer tests;    // how many test vectors run
    integer errors;   // how many of those failed

    // operation params (better organization for cases)
    localparam OP_ADD = 3'b000;   // add
    localparam OP_SUB = 3'b001;   // subtract
    localparam OP_AND = 3'b010;   // and
    localparam OP_OR  = 3'b011;   // or
    localparam OP_XOR = 3'b100;   // xor
    localparam OP_SLL = 3'b101;   // bit shift left logical (unsigned)
    localparam OP_SRL = 3'b110;   // bit shift right logical (unsigned)
    localparam OP_SRA = 3'b111;   // bit shift right arithmetic (signed)

    // waveform dump
    initial begin
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);
    end

    // task (applying one vector)
    task run_test;
        // inputs for task
        input [WIDTH-1:0] a_in;
        input [WIDTH-1:0] b_in;
        input [2:0] op_in;

        // expected values
        reg [WIDTH-1:0] exp_y;
        reg exp_overflow;
        reg exp_carry;
        reg exp_zero;
        reg exp_negative;

        reg [WIDTH:0] temp;

        begin
            // apply inputs to DUT
            a = a_in;
            b = b_in;
            op = op_in;

            #1;   // wait for combinational logic to settle

            // golden model (reference model)
            exp_overflow = 1'b0;
            exp_carry = 1'b0;

            temp_result = {(WIDTH+1){1'b0}};

            case (op_in)
                OP_ADD: begin
                    temp_result = {1'b0, a_in} + {1'b0, b_in};
                    exp_y = temp_result[WIDTH-1:0];
                    exp_carry = temp_result[WIDTH];
                    exp_overflow = (a_in[WIDTH-1] == b_in[WIDTH-1]) && (exp_y[WIDTH-1] != a_in[WIDTH-1]);
                end
                OP_SUB: begin
                    temp_result = {1'b0, a_in} - {1'b0, b_in};
                    exp_y = temp_result[WIDTH-1:0];
                    exp_carry = temp_result[WIDTH];
                    exp_overflow = (a_in[WIDTH-1] != b_in[WIDTH-1]) && (exp_y[WIDTH-1] != a_in[WIDTH-1]);
                end
                OP_AND: begin
                    exp_y = a_in & b_in;
                end
                OP_OR: begin
                    exp_y = a_in | b_in;
                end
                OP_XOR: begin
                    exp_y = a_in ^ b_in;
                end
                OP_SLL: begin
                    exp_y = (b_in >= WIDTH) ? (a_in << (WIDTH-1)) : (a_in << b_in);
                end
                OP_SRL: begin
                    exp_y = (b_in >= WIDTH) ? (a_in >> (WIDTH-1)) : (a_in >> b_in);
                end
                OP_SRA: begin
                    exp_y = (b_in >= WIDTH) ? ($signed(a_in) >>> (WIDTH-1)) : ($signed(a_in) >>> b_in);
                end
                default: begin
                    exp_y = {WIDTH{1'b0}};
                end
            endcase

            exp_zero = (exp_y == {WIDTH{1'b0}});
            exp_negative = exp_y[WIDTH-1];

            // bump test counter
            tests = tests + 1;

            if ((y !== exp_y) || 
                (overflow !== exp_overflow) || 
                (carry !== exp_carry) || 
                (zero !== exp_zero) || 
                (negative !== exp_negative)) begin

                // bump error counter
                errors = errors + 1;

                // error output
                $display("ERROR (test %0d, width=%0d): a=%0d, b=%0d, op=%b",
                        tests, WIDTH, a_in, b_in, op_in);
                $display("expected: y=%0d,       got: y=%0d", exp_y, y);
                $display("expected: carry=%b,    got: carry=%b", exp_carry, carry);
                $display("expected: overflow=%b, got: overflow=%b", exp_overflow, overflow);
                $display("expected: zero=%b,     got: zero=%b", exp_zero, zero);
                $display("expected: negative=%b, got: negative=%b", exp_negative, negative);
                $display("");
            end
        end
    endtask

    // test procedure
    initial begin
        tests = 0;
        errors = 0;

        // ADD 1 + 2
        run_test(1, 2, 3'b000);

        // SUB 10 - 3
        run_test(10, 3, 3'b001);

        // AND all ones & 0
        run_test({WIDTH{1'b1}}, 0, 3'b010);

        // OR all ones | 0
        run_test({WIDTH{1'b1}}, 0, 3'b011);

        // XOR: 0xAA ^ 0xFF (truncated to WIDTH)
        run_test('hAA, 'hFF, 3'b100);

        $display("Smoke test complete (WIDTH=%0d): tests=%0d errors=%0d (Add self-checking next)", 
                WIDTH, tests, errors);
        $finish;
    end
endmodule
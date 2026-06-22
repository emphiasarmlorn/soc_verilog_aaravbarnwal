module decoder (
    input  wire [15:0] inst,

    // one-hot instruction decode outputs
    output wire  y0,   // NOOP
    output wire  y1,   // INPUTC
    output wire  y2,   // INPUTCF
    output wire  y3,   // INPUTD
    output wire  y4,   // INPUTDF
    output wire  y5,   // MOVE
    output wire  y6,   // LOADI / LOADP
    output wire  y7,   // ADD
    output wire  y8,   // ADDI
    output wire  y9,   // SUB
    output wire  y10,  // SUBI
    output wire  y11,  // LOAD
    output wire  y12,  // LOADF
    output wire  y13,  // STORE
    output wire  y14,  // STOREF
    output wire  y15,  // SHIFTL
    output wire  y16,  // SHIFTR
    output wire  y17,  // CMP
    output wire  y18,  // JUMP
    output wire  y19,  // BRE / BRZ
    output wire  y20,  // BRNE / BRNZ
    output wire  y21,  // BRG
    output wire  y22,  // BRGE

    // register-select bits
    output wire [1:0] rx,   // inst[9:8]  = RX register select
    output wire [1:0] ry    // inst[11:10]= RY register select
);

    wire [3:0] cls  = inst[15:12];  // 4-bit class
    wire [1:0] ry_f = inst[11:10];  // RY / sub-opcode
    wire [1:0] rx_f = inst[9:8];    // RX / sub-opcode

    assign rx = rx_f;
    assign ry = ry_f;

    // 0000 : NOOP
    assign y0  = (cls == 4'b0000);

    // 0001 : INPUT
    assign y1  = (cls == 4'b0001) && (rx_f == 2'b00);   // INPUTC
    assign y2  = (cls == 4'b0001) && (rx_f == 2'b01);   // INPUTCF
    assign y3  = (cls == 4'b0001) && (rx_f == 2'b10);   // INPUTD
    assign y4  = (cls == 4'b0001) && (rx_f == 2'b11);   // INPUTDF

    // 0010 : MOVE
    assign y5  = (cls == 4'b0010);

    // 0011 : LOADI / LOADP
    assign y6  = (cls == 4'b0011);

    // 0100 : ADD
    assign y7  = (cls == 4'b0100);

    // 0101 : ADDI
    assign y8  = (cls == 4'b0101);

    // 0110 : SUB
    assign y9  = (cls == 4'b0110);

    // 0111 : SUBI
    assign y10 = (cls == 4'b0111);

    // 1000 : LOAD
    assign y11 = (cls == 4'b1000);

    // 1001 : LOADF
    assign y12 = (cls == 4'b1001);

    // 1010 : STORE
    assign y13 = (cls == 4'b1010);

    // 1011 : STOREF
    assign y14 = (cls == 4'b1011);

    // 1100 : SHIFTL / SHIFTR
    assign y15 = (cls == 4'b1100) && (inst[8] == 1'b0);  // SHIFTL
    assign y16 = (cls == 4'b1100) && (inst[8] == 1'b1);  // SHIFTR

    // 1101 : CMP
    assign y17 = (cls == 4'b1101);

    // 1110 : JUMP
    assign y18 = (cls == 4'b1110);

    // 1111 : Branch family
    assign y19 = (cls == 4'b1111) && (rx_f == 2'b00);   // BRE / BRZ
    assign y20 = (cls == 4'b1111) && (rx_f == 2'b01);   // BRNE / BRNZ
    assign y21 = (cls == 4'b1111) && (rx_f == 2'b10);   // BRG
    assign y22 = (cls == 4'b1111) && (rx_f == 2'b11);   // BRGE

endmodule

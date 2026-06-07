// 2 states: LEFT and RIGHT
// LEFT: walking left
// RIGHT: walking right
module lemmings_1(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    output walk_left,
    output walk_right); //  

    // parameter LEFT=0, RIGHT=1, ...
    parameter LEFT=0, RIGHT=1;
    reg state, next_state;

    always @(*) begin
        // State transition logic
        case (state)
            LEFT: next_state = bump_left ? RIGHT : LEFT;
            RIGHT: next_state = bump_right ? LEFT : RIGHT;
        endcase
    end

    always @(posedge clk, posedge areset) begin
        // State flip-flops with asynchronous reset
        if (areset) state <= LEFT;
        else state <= next_state;
    end

    // Output logic
    // assign walk_left = (state == ...);
    // assign walk_right = (state == ...);
    assign walk_left = (state==LEFT);
    assign walk_right = (state==RIGHT);

endmodule

// 4 states: LEFT, RIGHT, FALL_LEFT, FALL_RIGHT
// LEFT: walking left on ground
// RIGHT: walking right on ground
// FALL_LEFT: falling with memory of walking left
// FALL_RIGHT: falling with memory of walking right
module lemmings_2(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    output walk_left,
    output walk_right,
    output aaah ); 
    
    parameter LEFT=0, RIGHT=1, FALL_LEFT=2, FALL_RIGHT=3;
    reg [1:0] state, next;
    
    always @(*) begin
        case (state)
            LEFT: begin
                if (~ground) next = FALL_LEFT;
                else next = bump_left ? RIGHT : LEFT;
            end
            RIGHT: begin
                if (~ground) next = FALL_RIGHT;
                else next = bump_right ? LEFT : RIGHT;
            end
            FALL_LEFT: begin
                if (~ground) next = FALL_LEFT;
                else next = LEFT;
            end
            FALL_RIGHT: begin
                if (~ground) next = FALL_RIGHT;
                else next = RIGHT;
            end
        endcase
    end
    
    always @(posedge clk, posedge areset) begin
        if (areset) state <= LEFT;
        else state <= next;
    end
    
    assign walk_left = (state==LEFT);
    assign walk_right = (state==RIGHT);
    assign aaah = (~walk_left && ~walk_right);

endmodule

// 6 states: LEFT, RIGHT, FALL_LEFT, FALL_RIGHT, DIG_LEFT, DIG_RIGHT
// LEFT: walking left on ground
// RIGHT: walking right on ground
// FALL_LEFT: falling with memory of walking left
// FALL_RIGHT: falling with memory of walking right
// DIG_LEFT: digging with memory of walking left
// DIG_RIGHT: digging with memory of walking right
module lemmings_3(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging ); 
    
    parameter LEFT=0, RIGHT=1, FALL_LEFT=2, FALL_RIGHT=3, DIG_LEFT=4, DIG_RIGHT=5;
    reg [2:0] state, next;
    
    always @(*) begin
        case (state)
            LEFT: begin
                if (~ground) next = FALL_LEFT;
                else begin
                    if (dig) next = DIG_LEFT;
                    else next = bump_left ? RIGHT : LEFT;
                end
            end
            RIGHT: begin
                if (~ground) next = FALL_RIGHT;
                else begin 
                    if (dig) next = DIG_RIGHT;
                    else next = bump_right ? LEFT : RIGHT;
                end
            end
            FALL_LEFT: begin
                if (~ground) next = FALL_LEFT;
                else begin
                    next = LEFT;
                end
            end
            FALL_RIGHT: begin
                if (~ground) next = FALL_RIGHT;
                else begin
                    next = RIGHT;
                end
            end
            DIG_LEFT: begin
                if (ground) next = DIG_LEFT;
                else next = FALL_LEFT;
            end
            DIG_RIGHT: begin
                if (ground) next = DIG_RIGHT;
                else next = FALL_RIGHT;
            end
        endcase
    end
    
    always @(posedge clk, posedge areset) begin
        if (areset) state <= LEFT;
        else state <= next;
    end
    
    assign walk_left = (state==LEFT);
    assign walk_right = (state==RIGHT);
    assign aaah = (state==FALL_LEFT || state==FALL_RIGHT);
    assign digging = (state==DIG_LEFT || state==DIG_RIGHT);

endmodule

// 7 states: LEFT, RIGHT, FALL_LEFT, FALL_RIGHT, DIG_LEFT, DIG_RIGHT, SPLAT
// LEFT: walking left on ground
// RIGHT: walking right on ground
// FALL_LEFT: falling with memory of walking left
// FALL_RIGHT: falling with memory of walking right
// DIG_LEFT: digging with memory of walking left
// DIG_RIGHT: digging with memory of walking right
// SPLAT: dead state after more than 20 clock cycles of falling
module lemmings_4(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging ); 
    
    parameter LEFT=0, RIGHT=1, FALL_LEFT=2, FALL_RIGHT=3, DIG_LEFT=4, DIG_RIGHT=5, SPLAT=6;
    reg [2:0] state, next;
    reg [7:0] count;
    
    always @(*) begin
        next=state;
        case (state)
            LEFT: begin
                if (~ground) next = FALL_LEFT;
                else begin
                    if (dig) next = DIG_LEFT;
                    else next = bump_left ? RIGHT : LEFT;
                end
            end
            RIGHT: begin
                if (~ground) next = FALL_RIGHT;
                else begin 
                    if (dig) next = DIG_RIGHT;
                    else next = bump_right ? LEFT : RIGHT;
                end
            end
            FALL_LEFT: begin
                if (ground)
                    next = (count > 20) ? SPLAT : LEFT;
                else
                    next = FALL_LEFT;
            end
            FALL_RIGHT: begin
                if (ground)
                    next = (count > 20) ? SPLAT : RIGHT;
                else
                    next = FALL_RIGHT;
            end
            DIG_LEFT: begin
                if (ground) next = DIG_LEFT;
                else next = FALL_LEFT;
            end
            DIG_RIGHT: begin
                if (ground) next = DIG_RIGHT;
                else next = FALL_RIGHT;
            end
            SPLAT: next=SPLAT;
        endcase
    end
    
    always @(posedge clk, posedge areset) begin
        if (areset) begin 
            state <= LEFT;
            count <= 0;
        end
        else begin
            state <= next;
    
            // Entering a FALL state (transition from non-FALL to FALL)
            if ((next == FALL_LEFT || next == FALL_RIGHT) && 
                !(state == FALL_LEFT || state == FALL_RIGHT)) begin
                count <= 1;
            end
            // Already in FALL and still falling
            else if ((next == FALL_LEFT || next == FALL_RIGHT) && ~ground) begin
                count <= count + 1;
            end
            // Exit FALL or ground high
            else begin
                count <= 0;
            end
        end
    end
    
    assign walk_left = (state==LEFT);
    assign walk_right = (state==RIGHT);
    assign aaah = (state==FALL_LEFT || state==FALL_RIGHT);
    assign digging = (state==DIG_LEFT || state==DIG_RIGHT);

endmodule





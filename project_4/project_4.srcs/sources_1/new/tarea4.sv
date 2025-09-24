`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2025 11:26:28
// Design Name: 
// Module Name: tarea4
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tarea4(
    input  logic        clk,
    input  logic        reset,
    input  logic [7:0]  sw,
    input  logic        siguiente,
    input  logic        atras,
    output logic        ledprendido,
    output logic        ledapagado
);
    
    
    
    
    logic [18:0] div;
    logic        tick190;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            div    <= '0;
            tick190<= 1'b0;
        end else begin
            div    <= div + 1'b1;
            tick190<= (div == '0);   
        end
    end

    
    
    
    logic n0, n1, n1d;
    logic c0, c1, c1d;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            n0<=0; n1<=0; n1d<=0;
            c0<=0; c1<=0; c1d<=0;
        end else begin
            n0  <= siguiente;  n1  <= n0;  n1d <= n1;
            c0  <= atras;      c1  <= c0;  c1d <= c1;
        end
    end

    
    logic next_tick, check_tick;
    assign next_tick  = tick190 & (n1 & ~n1d);
    assign check_tick = tick190 & (c1 & ~c1d);

    
    
    
    typedef enum logic [2:0] {S_IDLE, S_D1, S_D2, S_D3, S_D4, S_DONE} state_t;
    state_t state_reg, state_next;

    
    logic [1:0] d1, d2, d3, d4;
    localparam logic [1:0] K1 = 2'b10,
                           K2 = 2'b00,
                           K3 = 2'b01,
                           K4 = 2'b10;

    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state_reg   <= S_IDLE;
            d1 <= '0; d2 <= '0; d3 <= '0; d4 <= '0;
            ledprendido <= 1'b0;
            ledapagado  <= 1'b0;
        end else begin
            state_reg <= state_next;
        end
    end

    
    always_comb begin
        state_next = state_reg;
        unique case (state_reg)
            S_IDLE: if (next_tick) state_next = S_D1;
            S_D1  : if (next_tick) state_next = S_D2;
            S_D2  : if (next_tick) state_next = S_D3;
            S_D3  : if (next_tick) state_next = S_D4;
            S_D4  : if (next_tick) state_next = S_DONE;
            S_DONE: if (check_tick) state_next = S_IDLE; 
            default: state_next = S_IDLE;
        endcase
    end

   
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            d1 <= '0; d2 <= '0; d3 <= '0; d4 <= '0;
            ledprendido <= 1'b0; ledapagado <= 1'b0;
        end else begin
            
            if (state_reg == S_DONE && state_next == S_IDLE) begin
                ledprendido <= 1'b0;
                ledapagado  <= 1'b0;
            end

            case (state_reg)
                S_D1: if (next_tick) d1 <= sw[7:6];
                S_D2: if (next_tick) d2 <= sw[5:4];
                S_D3: if (next_tick) d3 <= sw[3:2];
                S_D4: if (next_tick) d4 <= sw[1:0];

                S_DONE: if (check_tick) begin
                    if (d1==K1 && d2==K2 && d3==K3 && d4==K4) begin
                        ledprendido <= 1'b1;
                        ledapagado  <= 1'b0;
                    end else begin
                        ledprendido <= 1'b0;
                        ledapagado  <= 1'b1;
                    end
                end
                default: ;
            endcase
        end
    end
endmodule

 


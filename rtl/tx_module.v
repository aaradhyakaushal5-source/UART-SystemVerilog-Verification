`timescale 1ns / 1ps

module uart_sender(
    input clk,
    input wr_en,
    input enb,
    input rst,
    input [7:0] data_in,
    output reg tx,
    output tx_busy
);

    parameter STATE_IDLE  = 2'b00;
    parameter STATE_START = 2'b01;
    parameter STATE_DATA  = 2'b10;
    parameter STATE_STOP  = 2'b11;

    reg [7:0] data = 8'h00;
    reg [2:0] bitpos = 3'h0;
    reg [1:0] state = STATE_IDLE;

    always @(posedge clk) begin
        if (rst) begin
            tx     <= 1'b1; // Default UART idle line state is high
            state  <= STATE_IDLE;
            data   <= 8'h00;
            bitpos <= 3'h0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    tx <= 1'b1;
                    if (wr_en) begin
                        state  <= STATE_START;
                        data   <= data_in;
                        bitpos <= 3'h0;
                    end
                end
                
                STATE_START: begin
                    if (enb) begin
                        tx    <= 1'b0; // Send Start Bit
                        state <= STATE_DATA;
                    end
                end
                
                STATE_DATA: begin
                    if (enb) begin
                        tx <= data[bitpos];
                        if (bitpos == 3'h7) begin
                            state <= STATE_STOP;
                        end else begin
                            bitpos <= bitpos + 3'h1;
                        end
                    end
                end
                
                STATE_STOP: begin
                    if (enb) begin
                        tx    <= 1'b1; // Send Stop Bit
                        state <= STATE_IDLE;
                    end
                end
                
                default: begin
                    tx    <= 1'b1;
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

    assign tx_busy = (state != STATE_IDLE);

endmodule